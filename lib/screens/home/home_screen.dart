// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/providers/cart_provider.dart';
import 'package:satay_master_pro/providers/menu_provider.dart';
import 'package:satay_master_pro/screens/auth/login_screen.dart';
import 'package:satay_master_pro/widgets/cart_bottom_sheet.dart';
import 'package:satay_master_pro/widgets/category_header.dart';
import 'package:satay_master_pro/widgets/hero_banner.dart';
import 'package:satay_master_pro/widgets/animated/fade_in_widget.dart';
import 'package:satay_master_pro/widgets/product_card.dart';
import 'package:satay_master_pro/widgets/section_header.dart';
import 'package:satay_master_pro/widgets/animated/loading_widget.dart';
import 'package:satay_master_pro/widgets/empty_state_widget.dart';
import 'package:satay_master_pro/widgets/cart_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          const SliverToBoxAdapter(child: HeroBanner()),

          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryHeaderDelegate(
              child: CategoryHeader(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() => selectedCategory = category);
                },
              ),
            ),
          ),

          const SectionHeader(title: "Freshly Grilled for You 🔥"),

          menuAsync.when(
            data: (items) {
              final filteredItems = items.where((i) {
                final matchesCategory =
                    selectedCategory == "All" || i.category == selectedCategory;

                final matchesSearch =
                    i.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        i.category
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());

                return matchesCategory && matchesSearch;
              }).toList();

              if (filteredItems.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: EmptyStateWidget(
                      message: "No menu found.",
                      icon: Icons.fastfood,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.crossAxisExtent < 700 ? 2 : 3;

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 365,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return FadeInWidget(
                            delay: Duration(milliseconds: 100 * (index % 10)),
                            child: ProductCard(item: filteredItems[index]),
                          );
                        },
                        childCount: filteredItems.length,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingWidget(),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text("Error loading menu: $e")),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showCartSheet(context),
              backgroundColor: Colors.deepOrange,
              child: CartBadge(
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref) {
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
                searchQuery = "";
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

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const CartBottomSheet(),
    );
  }
}