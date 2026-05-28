import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../services/database_service.dart';

class OrderRepository {
  final DatabaseService _dbService;

  OrderRepository(this._dbService) {
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      // With persistence enabled, this will write to a local cache if offline
      // and sync automatically when the connection is restored.
      await _dbService.createOrder(order);
    } on FirebaseException catch (e) {
      // The repository can now handle specific data-layer exceptions
      // and re-throw them as custom, domain-specific exceptions if needed.
      throw Exception('Failed to place order: ${e.message}');
    }
  }

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _dbService.getUserOrders(uid);
  }
}
