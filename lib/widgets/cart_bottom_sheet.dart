import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/providers/cart_provider.dart';
import 'package:satay_master_pro/screens/auth/login_screen.dart';
import 'package:satay_master_pro/screens/checkout/checkout_screen.dart';
import 'price_row.dart';

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please login or sign up first before checkout."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Login / Sign Up"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value != null;

    final subtotal = cartNotifier.subtotal;
    final serviceFee = subtotal * 0.10;
    final total = subtotal + serviceFee;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Your Cart",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Divider(height: 32),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Your cart is empty"),
            )
          else
            ...cart.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${item.quantity} Set (${item.totalSticks} sticks)\n"
                  "Sauce: ${item.selectedSauces.join(', ')}"
                  "${item.extraSambal ? "\nExtra sambal added" : ""}",
                ),
                trailing: Text(
                  "RM ${item.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          PriceRow(label: "Subtotal", value: subtotal),
          PriceRow(label: "Service Fee (10%)", value: serviceFee),
          PriceRow(label: "Grand Total", value: total, isBold: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      if (!isLoggedIn) {
                        _showLoginRequiredDialog(context);
                        return;
                      }

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
              child: Text(
                isLoggedIn ? "PROCEED TO CHECKOUT" : "LOGIN TO CHECKOUT",
                style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
