import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satay_master_pro/screens/checkout/order_summary_section.dart';
import 'package:satay_master_pro/screens/checkout/payment_method_selection.dart';
import 'package:satay_master_pro/screens/checkout/pickup_details_form.dart';

import '../../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final pickupTimeController = TextEditingController();

  String? selectedPaymentMethod;
  bool isLoading = false;
  bool _hasPaid = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    pickupTimeController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
        const Duration(seconds: 2)); // Simulate payment processing

    if (!mounted) return;

    if (selectedPaymentMethod == "Online Banking") {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Online Banking Redirection"),
          content: const Text(
              "Simulating redirection to an online banking portal. Please confirm payment."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Confirm Payment"),
            ),
          ],
        ),
      ).then((value) {
        if (value == true) {
          setState(() {
            _hasPaid = true;
          });
        }
      });
    } else if (selectedPaymentMethod == "QR Pay") {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("QR Pay"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Please scan the QR code below to complete your payment."),
              const SizedBox(height: 16),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_many_purposes.svg', // Dummy QR code image
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("I have paid"),
            ),
          ],
        ),
      ).then((value) {
        if (value == true) {
          setState(() {
            _hasPaid = true;
          });
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final cartItems = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        pickupTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all pickup details")),
      );
      return;
    }

    if (!_hasPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete your payment first.")),
      );
      return;
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final subtotal = cartNotifier.subtotal;
      final serviceFee = subtotal * 0.10;
      final grandTotal = subtotal + serviceFee;

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'customerEmail': user.email,
        'customerName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'pickupTime': pickupTimeController.text.trim(),
        'paymentMethod': selectedPaymentMethod,
        'items': cartItems.map((item) {
          return {
            'itemId': item.product.id,
            'name': item.product.name,
            'sets': item.quantity,
            'sticks': item.totalSticks,
            'pricePerSet': item.product.price,
            'totalPrice': item.totalPrice,
          };
        }).toList(),
        'subtotal': subtotal,
        'serviceFee': serviceFee,
        'grandTotal': grandTotal,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Order Successful 🎉"),
          content: const Text("Your satay order has been placed successfully."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PickupDetailsForm(
              nameController: nameController,
              phoneController: phoneController,
              pickupTimeController: pickupTimeController,
            ),
            const SizedBox(height: 32),
            const OrderSummarySection(),
            const SizedBox(height: 32),
            PaymentMethodSelection(
              selectedPaymentMethod: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                  _hasPaid = false; // Reset payment status if method changes
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading || selectedPaymentMethod == null
                    ? null
                    : (_hasPaid ? placeOrder : _handlePayment),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_hasPaid ? "PLACE ORDER" : "PROCEED TO PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
