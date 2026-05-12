import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return OrderRepository(dbService);
});

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState != null) {
    return ref.watch(orderRepositoryProvider).getUserOrders(authState.uid);
  }
  return Stream.value([]);
});

// ANOMALY 4: State Management Anti-Pattern (GDVRR Audit)
// Using a global variable for "Last Viewed Item" instead of a Provider
OrderModel? lastViewedOrder;
