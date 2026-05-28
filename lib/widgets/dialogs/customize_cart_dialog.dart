
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satay_master_pro/models/satay_item.dart';
import 'package:satay_master_pro/providers/cart_provider.dart';

class CustomizeCartDialog extends ConsumerStatefulWidget {
  final SatayItem item;

  const CustomizeCartDialog({super.key, required this.item});

  @override
  ConsumerState<CustomizeCartDialog> createState() => _CustomizeCartDialogState();
}

class _CustomizeCartDialogState extends ConsumerState<CustomizeCartDialog> {
  late List<String> selectedSauces;
  late bool extraSambal;
  
  @override
  void initState() {
    super.initState();
    selectedSauces = [];
    extraSambal = false;
  }

  @override
  Widget build(BuildContext context) {
    final sauces = widget.item.sauces.isEmpty ? ['Sambal Kacang'] : widget.item.sauces;
    final maxSauceSelection =
        widget.item.maxSauceSelection <= 0 ? 2 : widget.item.maxSauceSelection;
    final extraPrice = extraSambal ? widget.item.extraSambalPrice : 0.0;
    final displayTotal = widget.item.price + extraPrice;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        "Customize ${widget.item.name}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Choose 1 to $maxSauceSelection sauce options",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...sauces.map((sauce) {
              final selected = selectedSauces.contains(sauce);

              return CheckboxListTile(
                value: selected,
                dense: true,
                activeColor: Colors.deepOrange,
                contentPadding: EdgeInsets.zero,
                title: Text(sauce),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      if (sauce == 'No Sauce') {
                        selectedSauces = ['No Sauce'];
                      } else {
                        selectedSauces.remove('No Sauce');

                        if (selectedSauces.length < maxSauceSelection) {
                          selectedSauces.add(sauce);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "You can only choose up to $maxSauceSelection sauces.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      selectedSauces.remove(sauce);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 12),
            if (widget.item.extraSambalAvailable)
              SwitchListTile(
                value: extraSambal,
                activeColor: Colors.deepOrange,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Add Extra Sambal 🌶️",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "+ RM ${widget.item.extraSambalPrice.toStringAsFixed(2)}",
                ),
                onChanged: (value) {
                  setState(() {
                    extraSambal = value;
                  });
                },
              ),
            const Divider(height: 28),
            Text(
              "Base price: RM ${widget.item.price.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (extraSambal)
              Text(
                "Extra sambal: RM ${widget.item.extraSambalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              "Total per set: RM ${displayTotal.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (selectedSauces.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please choose at least one sauce."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            ref.read(cartProvider.notifier).addToCart(
                  widget.item,
                  selectedSauces: selectedSauces,
                  extraSambal: extraSambal,
                  extraSambalPrice: widget.item.extraSambalPrice,
                );

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Added to cart with customization 🍢"),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text("ADD TO CART"),
        ),
      ],
    );
  }
}
