import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/providers/cart_provider.dart';

class OrderSummarySection extends ConsumerWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final subtotal = cartNotifier.subtotal;
    final serviceFee = 0.0;
    final grandTotal = subtotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Order Summary",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        ...cartItems.map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              item.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${item.quantity} Set (${item.totalSticks} sticks)",
            ),
            trailing: Text(
              "RM ${item.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Divider(height: 32),
        _priceRow("Subtotal", subtotal),
        _priceRow("Service Fee (0%)", serviceFee),
        _priceRow("Grand Total", grandTotal, isBold: true),
      ],
    );
  }

  Widget _priceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "RM ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.deepOrange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
