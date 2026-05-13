import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_page.dart'; // Import OrdersPage
import 'profile/profile_page.dart'; // Import ProfilePage

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int selectedIndex = 0;

  void onTabChange(int index) {
    final user = ref.read(authStateProvider).value;

    if (index != 0 && user == null) {
      _showLoginDialog();
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Required 🔐"),
          content: const Text("Please login first to access this feature."),
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
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const CartScreen(),
      const OrdersPage(), // Use the imported OrdersPage
      const ProfilePage(), // Use the imported ProfilePage
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: GNav(
              selectedIndex: selectedIndex,
              onTabChange: onTabChange,
              rippleColor: Colors.deepOrange.shade100,
              hoverColor: Colors.deepOrange.shade50,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: Colors.deepOrange,
              color: Colors.grey,
              tabs: const [
                GButton(icon: Icons.restaurant_menu, text: 'Menu'),
                GButton(icon: Icons.shopping_cart, text: 'Cart'),
                GButton(icon: Icons.receipt_long, text: 'Orders'),
                GButton(icon: Icons.person, text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
