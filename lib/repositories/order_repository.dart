import '../models/order_model.dart';
import '../services/database_service.dart';

class OrderRepository {
  final DatabaseService _dbService;

  OrderRepository(this._dbService);

  Future<void> placeOrder(OrderModel order) async {
    // ANOMALY 3: Offline Persistence Failure (GDVRR Audit)
    // No local queueing or connectivity check.
    // If the device is offline, this call will simply time out or fail.
    await _dbService.createOrder(order);
  }

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _dbService.getUserOrders(uid);
  }
}
