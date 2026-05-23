// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';

class PaymentMethodSelection extends StatelessWidget {
  final String? selectedPaymentMethod;
  final ValueChanged<String?> onChanged;

  const PaymentMethodSelection({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        RadioListTile<String>(
          title: const Text("Online Banking"),
          value: "Online Banking",
          groupValue: selectedPaymentMethod,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text("QR Pay"),
          value: "QR Pay",
          groupValue: selectedPaymentMethod,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
