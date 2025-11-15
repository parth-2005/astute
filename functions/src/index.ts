import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {logger} from "firebase-functions"; // Use the official logger
import {setGlobalOptions} from "firebase-functions/v2";

admin.initializeApp();
// Set default region for v2 functions
setGlobalOptions({region: "asia-south1"});
const db = admin.firestore();

// --- Constants for Readability & Maintenance ---
const POT_TOTAL = 10.0;
const PRICE_PRECISION = 6; // From your .toFixed(6)

// --- Add a Type for Safety ---
type Order = {
  marketId: string;
  side: "yes" | "no";
  quantity: number;
  price: number;
  status: "pending" | "executed" | "cancelled";
};

/**
 * Triggered on any new order creation.
 * Checks for a matching complementary order to execute a trade atomically.
 */
const matchOrder = onDocumentWritten("orders/{orderId}", async (event) => {
  // 1. Only run on "create" events
  const before = event.data?.before;
  const after = event.data?.after;

  if (before?.exists || !after?.exists) {
    // Not a create event (it's an update or delete), so we don't match.
    return null;
  }

  const newOrderData = after.data() as Order;
  const newOrderRef = after.ref;
  const {orderId} = event.params;

  // 2. Only run if the new order is 'pending'
  if (newOrderData.status !== "pending") {
    logger.log(`Order ${orderId} is not pending. Exiting.`);
    return null;
  }

  logger.info(`Processing new pending order: ${orderId}`, {
    order: newOrderData,
  });

  // 3. Calculate complementary order details
  const complementarySide = newOrderData.side === "yes" ? "no" : "yes";
  const complementaryPrice = parseFloat(
    (POT_TOTAL - newOrderData.price).toFixed(PRICE_PRECISION),
  );

  // 4. Run the match inside a Transaction to prevent race conditions
  try {
    await db.runTransaction(async (transaction) => {
      // 5. Build the query *inside* the transaction
      const matchQuery = db
        .collection("orders")
        .where("marketId", "==", newOrderData.marketId)
        .where("side", "==", complementarySide)
        .where("price", "==", complementaryPrice)
        .where("quantity", "==", newOrderData.quantity)
        .where("status", "==", "pending")
        // CRITICAL FIX: Do not match with yourself!
        .where(admin.firestore.FieldPath.documentId(), "!=", orderId)
        .limit(1);

      // 6. Get market data first (all reads must come before writes)
      const marketRef = db.collection("markets").doc(newOrderData.marketId);
      const marketDoc = await transaction.get(marketRef);

      // 7. Get query results *inside* the transaction
      const matchSnapshot = await transaction.get(matchQuery);

      if (matchSnapshot.empty) {
        logger.info(`No match found for order ${orderId}.`, {
          lookingFor: {
            marketId: newOrderData.marketId,
            side: complementarySide,
            price: complementaryPrice,
          },
        });
        // No match, just exit the transaction successfully.
        return;
      }

      // 8. A match was found!
      const matchedDoc = matchSnapshot.docs[0];
      const matchedRef = matchedDoc.ref;
      const matchedId = matchedDoc.id;

      logger.info(`Match FOUND: ${orderId} <> ${matchedId}. Executing trade.`);

      const executionTime = admin.firestore.FieldValue.serverTimestamp();

      // 9. Update both orders *inside* the transaction
      transaction.update(newOrderRef, {
        status: "executed",
        executedAt: executionTime,
        executedPrice: newOrderData.price,
        matchedWith: matchedId, // Good for auditing
      });

      transaction.update(matchedRef, {
        status: "executed",
        executedAt: executionTime,
        executedPrice: complementaryPrice,
        matchedWith: orderId, // Good for auditing
      });

      if (marketDoc.exists) {
        const marketData = marketDoc.data();
        const currentYesPrice = marketData?.yes_price ||
          marketData?.yesPrice || 0.5;
        const currentNoPrice = marketData?.no_price ||
          marketData?.noPrice || 0.5;

        // Calculate new market rates based on the executed trade price
        // Set market price directly from the executed trade
        let newYesPrice: number;
        let newNoPrice: number;

        if (newOrderData.side === "yes") {
          // Yes order executed - set yes price from executed price
          newYesPrice = newOrderData.price / POT_TOTAL;
          newNoPrice = (POT_TOTAL - newOrderData.price) / POT_TOTAL;
        } else {
          // No order executed - set no price from executed price
          newNoPrice = newOrderData.price / POT_TOTAL;
          newYesPrice = (POT_TOTAL - newOrderData.price) / POT_TOTAL;
        }

        // Prices are already complementary (always add up to 1.0)

        // Ensure prices stay within reasonable bounds (0.01 to 0.99)
        newYesPrice = Math.max(0.01, Math.min(0.99, newYesPrice));
        newNoPrice = Math.max(0.01, Math.min(0.99, newNoPrice));

        // Update market with new prices
        transaction.update(marketRef, {
          yes_price: parseFloat(newYesPrice.toFixed(PRICE_PRECISION)),
          no_price: parseFloat(newNoPrice.toFixed(PRICE_PRECISION)),
          // Support both naming conventions
          yesPrice: parseFloat(newYesPrice.toFixed(PRICE_PRECISION)),
          noPrice: parseFloat(newNoPrice.toFixed(PRICE_PRECISION)),
          volume: (marketData?.volume || 0) + newOrderData.quantity,
          lastTradeAt: executionTime,
        });

        // 11. Add price history entry
        const priceHistoryRef = marketRef.collection("price_history")
          .doc();
        transaction.set(priceHistoryRef, {
          timestamp: executionTime,
          yes: parseFloat(newYesPrice.toFixed(PRICE_PRECISION)),
          no: parseFloat(newNoPrice.toFixed(PRICE_PRECISION)),
          yes_price: parseFloat(newYesPrice.toFixed(PRICE_PRECISION)),
          no_price: parseFloat(newNoPrice.toFixed(PRICE_PRECISION)),
          volume: newOrderData.quantity,
          executedPrice: newOrderData.price,
          side: newOrderData.side,
        });

        logger.info(`Updated market rates for ${newOrderData.marketId}`, {
          oldYes: currentYesPrice,
          oldNo: currentNoPrice,
          newYes: newYesPrice,
          newNo: newNoPrice,
        });
      }
    });

    logger.info(`Transaction successful for order: ${orderId}`);
    return null;
  } catch (err) {
    logger.error(`Transaction failed for order ${orderId}:`, err);
    return null;
  }
});

export {matchOrder};

