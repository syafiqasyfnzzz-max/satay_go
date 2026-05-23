import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/order_model.dart';
import '../models/satay_item.dart';

class DatabaseService {
  FirebaseFirestore get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      throw Exception("Firebase not initialized");
    }
  }

  Future<void> saveUser(AppUser user) async {
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Database Error: $e");
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      var doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint("Database Error: $e");
    }
    return null;
  }

  Stream<List<SatayItem>> getMenuItems() {
    try {
      return _db.collection('menuItems').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => SatayItem.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      debugPrint("Database Stream Error: $e");
      return Stream.value([
        SatayItem(
          id: '1',
          name: 'Premium Chicken Satay',
          category: 'Chicken',
          price: 15.0,
          imageUrl:
              'https://images.unsplash.com/photo-1541529086526-db283c563270?q=80&w=400',
          isAvailable: true,
          tag: 'Bestseller',
        ),
        SatayItem(
          id: '2',
          name: 'Spicy Beef Satay',
          category: 'Beef',
          price: 18.0,
          imageUrl:
              'https://images.unsplash.com/photo-1529692236671-f1f6e9460272?q=80&w=400',
          isAvailable: true,
          tag: 'Popular',
        ),
      ]);
    }
  }

  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getUserOrders(String uid) {
    try {
      return _db
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }
}
