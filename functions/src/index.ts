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

      // 6. Get query results *inside* the transaction
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

      // 7. A match was found!
      const matchedDoc = matchSnapshot.docs[0];
      const matchedRef = matchedDoc.ref;
      const matchedId = matchedDoc.id;

      logger.info(`Match FOUND: ${orderId} <> ${matchedId}. Executing trade.`);

      const executionTime = admin.firestore.FieldValue.serverTimestamp();

      // 8. Update both orders *inside* the transaction
      transaction.update(newOrderRef, {
        status: "executed",
        executedAt: executionTime,
        matchedWith: matchedId, // Good for auditing
      });

      transaction.update(matchedRef, {
        status: "executed",
        executedAt: executionTime,
        matchedWith: orderId, // Good for auditing
      });
    });

    logger.info(`Transaction successful for order: ${orderId}`);
    return null;
  } catch (err) {
    logger.error(`Transaction failed for order ${orderId}:`, err);
    return null;
  }
});

export {matchOrder};

