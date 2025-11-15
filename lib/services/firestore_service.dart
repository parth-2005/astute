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

  Stream<List<Order>> getPendingOrders() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(<Order>[]);
    }

    return _db
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        // align keys with Order.fromJson expectations
        if (map.containsKey('createdAt')) {
          map['created_at'] = map['createdAt'];
        }
        if (map.containsKey('executedAt')) {
          map['executed_at'] = map['executedAt'];
        }
        if (map.containsKey('marketName')) {
          map['market_name'] = map['marketName'];
        }
        if (map.containsKey('marketId')) {
          map['market_id'] = map['marketId'];
        }
        if (map.containsKey('executedPrice')) {
          map['executed_price'] = map['executedPrice'];
        }
        return Order.fromJson(map);
      }).toList();
    });
  }

  /// Stream a single Market document as a Market model
  Stream<Market> getMarketById(String marketId) {
    final docRef = _db.collection('markets').doc(marketId);
    return docRef.snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
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
        final d = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        // ensure timestamp key exists
        if (d.containsKey('timestamp')) {
          d['timestamp'] = d['timestamp'];
        }
        return d;
      }).toList();
    });
  }
}
