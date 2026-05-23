// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
