import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/satay_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isSearching = false; // To toggle search mode

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          const SliverToBoxAdapter(child: _HeroBanner()),
          SliverToBoxAdapter(child: _buildCategoryScroll()),
          const _SectionHeader(title: "Freshly Grilled for You 🔥"),
          menuAsync.when(
            data: (items) {
              // Updated filtering logic to include searchQuery
              final filteredItems = items.where((i) {
                final matchesCategory = selectedCategory == "All" || i.category == selectedCategory;
                final matchesSearch = i.name.toLowerCase().contains(searchQuery.toLowerCase());
                return matchesCategory && matchesSearch;
              }).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 450,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return _ProductCard(item: filteredItems[index]);
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text("Error loading menu: $e")),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showCartSheet(context),
        label: Text(
          "View Cart (${cart.length}) • RM ${ref.read(cartProvider.notifier).subtotal.toStringAsFixed(2)}",
        ),
        icon: const Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
        ),
      )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value != null;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: isSearching
          ? TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          hintText: "Search your favorite satay...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      )
          : const Text(
        "SatayGo 🔥",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.deepOrange,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                searchQuery = ""; // Clear search when closing
              }
            });
          },
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            if (!isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You are already logged in")),
              );
            }
          },
          icon: Icon(
            isLoggedIn ? Icons.person : Icons.person_outline,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryScroll() {
    final categories = [
      {"label": "All", "emoji": "🔥", "width": 110.0},
      {"label": "Chicken", "emoji": "🐔", "width": 160.0},
      {"label": "Beef", "emoji": "🥩", "width": 130.0},
      {"label": "Lamb", "emoji": "🐑", "width": 130.0},
      {"label": "Combo", "emoji": "🍱", "width": 145.0},
    ];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final label = categories[index]["label"] as String;
          final emoji = categories[index]["emoji"] as String;
          final width = categories[index]["width"] as double;
          final isSelected = selectedCategory == label;

          return SizedBox(
            width: width,
            height: 52,
            child: ChoiceChip(
              selected: isSelected,
              selectedColor: Colors.deepOrange,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color:
                  isSelected ? Colors.deepOrange : Colors.orange.shade100,
                ),
              ),
              label: Center(
                child: Text(
                  "$emoji  $label",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              onSelected: (_) {
                setState(() => selectedCategory = label);
              },
            ),
          );
        },
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _CartBottomSheet(),
    );
  }
}

// ... Rest of the original code (SectionHeader, ProductCard, HeroBanner, CartBottomSheet, etc.) remains exactly the same

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final SatayItem item;

  const _ProductCard({required this.item});

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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE64A19), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Satay Fiesta! 🍢🔥",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Hot, smoky, and freshly grilled — order your favourite set today.",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet();

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
          _PriceRow(label: "Subtotal", value: subtotal),
          _PriceRow(label: "Service Fee (10%)", value: serviceFee),
          _PriceRow(label: "Grand Total", value: total, isBold: true),
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

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _PriceRow({
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
