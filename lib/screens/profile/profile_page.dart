import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<int> _getOrderCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .get();

    return snapshot.docs.length;
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final cart = ref.watch(cartProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAF5),
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: const Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(user.uid),
        builder: (context, userSnapshot) {
          final userData = userSnapshot.data;

          final name = userData?['name'] ?? "SatayGo Customer";
          final phone = userData?['phone'] ?? "Not provided";
          final role = userData?['role'] ?? "user";

          return FutureBuilder<int>(
            future: _getOrderCount(user.uid),
            builder: (context, orderSnapshot) {
              final orderCount = orderSnapshot.data ?? 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE64A19),
                            Color(0xFFFF7043),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 46,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email ?? "No email",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Role: ${role.toString().toUpperCase()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.receipt_long,
                            title: "Orders",
                            value: "$orderCount",
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.shopping_cart,
                            title: "Cart Items",
                            value: "${cart.length}",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _InfoSection(
                      title: "Account Details",
                      children: [
                        _InfoTile(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: user.email ?? "No email",
                        ),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          value: phone,
                        ),
                        _InfoTile(
                          icon: Icons.verified_user_outlined,
                          title: "Account Type",
                          value: role.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: "SatayGo Services",
                      children: const [
                        _InfoTile(
                          icon: Icons.storefront,
                          title: "Pickup Only",
                          value: "Available at our store location",
                        ),
                        _InfoTile(
                          icon: Icons.restaurant_menu,
                          title: "Minimum Order",
                          value: "1 set = 10 sticks",
                        ),
                        _InfoTile(
                          icon: Icons.payment,
                          title: "Payment",
                          value: "Online Banking / QR Pay",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Logged out successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("LOGOUT"),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.deepOrange.withOpacity(0.1),
            child: Icon(
              icon,
              size: 19,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
