import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;

import 'package:satay_master_pro/models/order_model.dart';
import 'package:satay_master_pro/repositories/order_repository.dart';
import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/providers/cart_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
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

class CheckoutState {
  final bool isLoading;
  final String? errorMessage;

  CheckoutState({
    this.isLoading = false,
    this.errorMessage,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CheckoutNotifier extends legacy.StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(CheckoutState());

  Future<void> placeOrder({
    required String customerName,
    required String phone,
    required String pickupTime,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final user = _ref.read(authStateProvider).value;
    final cartItems = _ref.read(cartProvider);

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Please login first",
      );
      throw Exception("User not logged in");
    }

    if (cartItems.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Your cart is empty",
      );
      throw Exception("Cart is empty");
    }

    try {
      final cartNotifier = _ref.read(cartProvider.notifier);

      final subtotal = cartNotifier.subtotal;

      // NO SERVICE FEE
     final serviceFee = 0.0;
     final grandTotal = subtotal;

      final order = OrderModel(
        userId: user.uid,
        customerEmail: user.email,
        customerName: customerName,
        phone: phone,
        pickupTime: pickupTime,
        paymentMethod: paymentMethod,
        items: cartItems,
        subtotal: subtotal,
        serviceFee: serviceFee,
        grandTotal: grandTotal,
      );

      await _ref.read(orderRepositoryProvider).placeOrder(order);

      _ref.read(cartProvider.notifier).clear();

      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      throw Exception("Failed to place order: $e");
    }
  }
}

final checkoutNotifierProvider =
    legacy.StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});