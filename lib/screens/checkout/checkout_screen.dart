import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satay_master_pro/providers/order_provider.dart';
import 'package:satay_master_pro/screens/checkout/order_summary_section.dart';
import 'package:satay_master_pro/screens/checkout/payment_method_selection.dart';
import 'package:satay_master_pro/screens/checkout/pickup_details_form.dart';

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
  bool _isPaymentLoading = false;
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

    setState(() => _isPaymentLoading = true);

    await Future.delayed(
        const Duration(seconds: 2)); // Simulate payment processing

    if (!mounted) return;

    bool paymentConfirmed = false;
    if (selectedPaymentMethod == "Online Banking") {
      paymentConfirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Online Banking Redirection"),
              content: const Text(
                  "Simulating redirection to an online banking portal. Please confirm payment."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirm Payment"),
                ),
              ],
            ),
          ) ??
          false;
    } else if (selectedPaymentMethod == "QR Pay") {
      paymentConfirmed = await showDialog(
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
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("I have paid"),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (paymentConfirmed) {
      setState(() {
        _hasPaid = true;
      });
    }

    setState(() => _isPaymentLoading = false);
  }

  Future<void> _placeOrder() async {
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

    try {
      await ref.read(checkoutNotifierProvider.notifier).placeOrder(
            customerName: nameController.text.trim(),
            phone: phoneController.text.trim(),
            pickupTime: pickupTimeController.text.trim(),
            paymentMethod: selectedPaymentMethod!,
          );

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
        SnackBar(content: Text("Failed to place order: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final isLoading = checkoutState.isLoading || _isPaymentLoading;

    ref.listen<CheckoutState>(checkoutNotifierProvider, (_, state) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      }
    });

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
                    : (_hasPaid ? _placeOrder : _handlePayment),
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
