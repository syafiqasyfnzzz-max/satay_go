// ignore_for_file: prefer_const_literals_to_create_immutables, deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:satay_master_pro/widgets/cart_badge.dart';

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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
            onTabChange: (index) {
              HapticFeedback.lightImpact();
              onTabChange(index);
            },
            rippleColor: Colors.deepOrange.shade100,
            hoverColor: Colors.deepOrange.shade50,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            duration: const Duration(milliseconds: 350),
            tabBackgroundColor: Colors.deepOrange,
            color: Colors.grey.shade600,
            tabs: [
              const GButton(icon: Icons.restaurant_menu_outlined, text: 'Menu'),
              GButton(
                icon: Icons.shopping_cart_outlined,
                text: 'Cart',
                leading: const CartBadge(
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              ),
              const GButton(
                  icon: Icons.receipt_long_outlined, text: 'Orders'),
              const GButton(icon: Icons.person_outline, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
