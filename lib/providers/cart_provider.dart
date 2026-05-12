import 'package:flutter_riverpod/legacy.dart';

import '../models/cart_item.dart';
import '../models/satay_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(
    SatayItem item, {
    List<String> selectedSauces = const [],
    bool extraSambal = false,
    double extraSambalPrice = 0.0,
  }) {
    final existingIndex = state.indexWhere(
      (cartItem) =>
          cartItem.product.id == item.id &&
          _sameSauces(cartItem.selectedSauces, selectedSauces) &&
          cartItem.extraSambal == extraSambal,
    );

    if (existingIndex != -1) {
      final updatedCart = [...state];
      final existingItem = updatedCart[existingIndex];

      updatedCart[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );

      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(
          product: item,
          quantity: 1,
          selectedSauces: selectedSauces,
          extraSambal: extraSambal,
          extraSambalPrice: extraSambalPrice,
        ),
      ];
    }
  }

  bool _sameSauces(List<String> a, List<String> b) {
    if (a.length != b.length) return false;

    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();

    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }

    return true;
  }

  void updateQuantity(String id, int change) {
    state = [
      for (final item in state)
        if (item.product.id == id)
          item.copyWith(
            quantity: (item.quantity + change).clamp(1, 999),
          )
        else
          item,
    ];
  }

  void removeItem(String id) {
    state = state.where((item) => item.product.id != id).toList();
  }

  void clear() {
    state = [];
  }

  double get subtotal {
    return state.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
