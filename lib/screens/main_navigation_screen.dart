import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satay_master_pro/widgets/custom_bottom_nav_bar.dart';

import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/screens/auth/login_screen.dart';
import 'package:satay_master_pro/screens/cart/cart_screen.dart';
import 'package:satay_master_pro/screens/home/home_screen.dart';
import 'package:satay_master_pro/screens/orders/orders_page.dart';
import 'package:satay_master_pro/screens/profile/profile_page.dart';

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
      const OrdersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
      ),
    );
  }
}
