import 'package:flutter/material.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
          Text(
            "RM ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isBold ? Colors.deepOrange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
