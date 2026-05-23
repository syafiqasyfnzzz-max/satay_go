// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/models/satay_item.dart';
import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/providers/cart_provider.dart';
import 'package:satay_master_pro/screens/auth/login_screen.dart';

class ProductCard extends ConsumerWidget {
  final SatayItem item;

  const ProductCard({super.key, required this.item});

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text(
            "Please login or sign up first to place your satay order 🍢",
          ),
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

  void _showCustomizeCartDialog(
    BuildContext context,
    WidgetRef ref,
    SatayItem item,
  ) {
    List<String> selectedSauces = [];
    bool extraSambal = false;

    final sauces = item.sauces.isEmpty ? ['Sambal Kacang'] : item.sauces;
    final maxSauceSelection =
        item.maxSauceSelection <= 0 ? 2 : item.maxSauceSelection;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final extraPrice = extraSambal ? item.extraSambalPrice : 0.0;
            final displayTotal = item.price + extraPrice;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                "Customize ${item.name}",
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
                          setDialogState(() {
                            if (checked == true) {
                              if (sauce == 'No Sauce') {
                                selectedSauces = ['No Sauce'];
                              } else {
                                selectedSauces.remove('No Sauce');

                                if (selectedSauces.length <
                                    maxSauceSelection) {
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
                    if (item.extraSambalAvailable)
                      SwitchListTile(
                        value: extraSambal,
                        activeColor: Colors.deepOrange,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Add Extra Sambal 🌶️",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "+ RM ${item.extraSambalPrice.toStringAsFixed(2)}",
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            extraSambal = value;
                          });
                        },
                      ),
                    const Divider(height: 28),
                    Text(
                      "Base price: RM ${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (extraSambal)
                      Text(
                        "Extra sambal: RM ${item.extraSambalPrice.toStringAsFixed(2)}",
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
                          item,
                          selectedSauces: selectedSauces,
                          extraSambal: extraSambal,
                          extraSambalPrice: item.extraSambalPrice,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 270,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  height: 270,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    );
                  },
                ),
                if (item.tag.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "RM ${item.price.toStringAsFixed(2)} / set",
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Choose sauce + add extra sambal",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "1 Set = 10 sticks",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            item.isAvailable ? Colors.deepOrange : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: item.isAvailable
                          ? () {
                              if (!isLoggedIn) {
                                _showLoginRequiredDialog(context);
                                return;
                              }

                              _showCustomizeCartDialog(context, ref, item);
                            }
                          : null,
                      child: Text(
                        item.isAvailable
                            ? isLoggedIn
                                ? "Customize & Add"
                                : "Login to Order"
                            : "Out of Stock",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
