import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/market.dart';
import '../models/order.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Market>> getTrendingMarkets() {
    return _db.collection('markets').limit(10).snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return Market.fromJson(map);
      }).toList();
    });
  }

  Future<void> placeOrder({
    required String marketId,
    required String marketName,
    required bool isYes,
    required int quantity,
    required double price,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final orderData = {
      'userId': currentUser.uid,
      'marketId': marketId,
      'marketName': marketName,
      'side': isYes ? 'yes' : 'no',
      'quantity': quantity,
      'price': price,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('orders').add(orderData);
  }

  Stream<List<Order>> getPendingOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<Order>[]);
    }
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        // align keys with Order.fromJson expectations
        if (map.containsKey('createdAt')) map['created_at'] = map['createdAt'];
        if (map.containsKey('executedAt')) map['executed_at'] = map['executedAt'];
        if (map.containsKey('marketName')) map['market_name'] = map['marketName'];
        if (map.containsKey('marketId')) map['market_id'] = map['marketId'];
        if (map.containsKey('executedPrice')) map['executed_price'] = map['executedPrice'];
        return Order.fromJson(map);
      }).toList();
    });
  }

  /// Stream a single Market document as a Market model
  Stream<Market> getMarketById(String marketId) {
    final docRef = _db.collection('markets').doc(marketId);
    return docRef.snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        // Return a minimal Market if document doesn't exist yet
        return Market(
          id: doc.id,
          name: 'Unknown',
          description: '',
          category: '',
          resolutionTime: DateTime.now(),
          yesPrice: 0.5,
          noPrice: 0.5,
          liquidity: 0,
          volume: 0,
        );
      }
      final map = Map<String, dynamic>.from(data);
      map['id'] = doc.id;
      return Market.fromJson(map);
    });
  }

  /// Stream price history for a market. Expects a subcollection `price_history` under the market
  /// where each doc contains at least: `timestamp` (Firestore Timestamp), `yes` (number), `no` (number).
  Stream<List<Map<String, dynamic>>> getMarketPriceHistory(String marketId) {
    final coll = _db.collection('markets').doc(marketId).collection('price_history').orderBy('timestamp');
    return coll.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final d = Map<String, dynamic>.from(doc.data());
        // ensure timestamp key exists
        if (d.containsKey('timestamp')) {
          d['timestamp'] = d['timestamp'];
        }
        return d;
      }).toList();
    });
  }

  /// Stream user's positions (executed orders from active markets)
  Stream<List<Order>> getUserPositions(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<Order>[]);
    }
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'executed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        // Align keys with Order.fromJson expectations
        if (map.containsKey('createdAt')) map['created_at'] = map['createdAt'];
        if (map.containsKey('executedAt')) map['executed_at'] = map['executedAt'];
        if (map.containsKey('marketName')) map['market_name'] = map['marketName'];
        if (map.containsKey('marketId')) map['market_id'] = map['marketId'];
        if (map.containsKey('executedPrice')) map['executed_price'] = map['executedPrice'];
        return Order.fromJson(map);
      }).toList();
    });
  }

  /// Stream user's order history (cancelled, expired, rejected orders)
  Stream<List<Order>> getOrderHistory(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<Order>[]);
    }
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['cancelled', 'expired', 'rejected'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        // Align keys with Order.fromJson expectations
        if (map.containsKey('createdAt')) map['created_at'] = map['createdAt'];
        if (map.containsKey('executedAt')) map['executed_at'] = map['executedAt'];
        if (map.containsKey('marketName')) map['market_name'] = map['marketName'];
        if (map.containsKey('marketId')) map['market_id'] = map['marketId'];
        if (map.containsKey('executedPrice')) map['executed_price'] = map['executedPrice'];
        return Order.fromJson(map);
      }).toList();
    });
  }

  /// Get all markets (for market list screen)
  Stream<List<Market>> getAllMarkets() {
    return _db.collection('markets').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return Market.fromJson(map);
      }).toList();
    });
  }

  /// Get markets by category
  Stream<List<Market>> getMarketsByCategory(String category) {
    return _db
        .collection('markets')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return Market.fromJson(map);
      }).toList();
    });
  }

  /// Stream all pending orders for a specific market (order book)
  Stream<List<Order>> getMarketOrderBook(String marketId) {
    return _db
        .collection('orders')
        .where('marketId', isEqualTo: marketId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        // align keys with Order.fromJson expectations
        if (map.containsKey('createdAt')) map['created_at'] = map['createdAt'];
        if (map.containsKey('executedAt')) map['executed_at'] = map['executedAt'];
        if (map.containsKey('marketName')) map['market_name'] = map['marketName'];
        if (map.containsKey('marketId')) map['market_id'] = map['marketId'];
        if (map.containsKey('executedPrice')) map['executed_price'] = map['executedPrice'];
        return Order.fromJson(map);
      }).toList();
    });
  }
}
