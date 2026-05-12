import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  final pages = const [
    AdminAnalyticsPage(),
    AdminMenuPage(),
    AdminOrdersPage(),
    AdminAccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        indicatorColor: Colors.deepOrange.shade100,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: "Menu",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: "Admin",
          ),
        ],
      ),
    );
  }
}

/* =========================
   ADMIN DASHBOARD
========================= */

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  Future<Map<String, dynamic>> _getDashboardData() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    final menuSnapshot =
        await FirebaseFirestore.instance.collection('menu').get();

    double totalSales = 0;
    int pendingOrders = 0;
    int preparingOrders = 0;
    int completedOrders = 0;

    for (final doc in ordersSnapshot.docs) {
      final data = doc.data();
      totalSales += ((data['grandTotal'] ?? 0) as num).toDouble();

      final status = data['status'] ?? 'Pending';
      if (status == 'Pending') pendingOrders++;
      if (status == 'Preparing') preparingOrders++;
      if (status == 'Completed') completedOrders++;
    }

    return {
      'totalSales': totalSales,
      'totalOrders': ordersSnapshot.docs.length,
      'menuCount': menuSnapshot.docs.length,
      'pendingOrders': pendingOrders,
      'preparingOrders': preparingOrders,
      'completedOrders': completedOrders,
    };
  }

  @override
  Widget build(BuildContext context) {
    final adminEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getDashboardData(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};

          final totalSales = data['totalSales'] ?? 0.0;
          final totalOrders = data['totalOrders'] ?? 0;
          final menuCount = data['menuCount'] ?? 0;
          final pendingOrders = data['pendingOrders'] ?? 0;
          final preparingOrders = data['preparingOrders'] ?? 0;
          final completedOrders = data['completedOrders'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE64A19), Color(0xFFFF7043)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome, SatayGo Admin 🍢",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminEmail,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Monitor sales, menu items, and customer orders.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Business Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "Total Sales",
                      value:
                          "RM ${(totalSales as num).toDouble().toStringAsFixed(2)}",
                      icon: Icons.payments,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _DashboardCard(
                      title: "Orders",
                      value: "$totalOrders",
                      icon: Icons.receipt_long,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "Menu Items",
                      value: "$menuCount",
                      icon: Icons.restaurant_menu,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _DashboardCard(
                      title: "Pending",
                      value: "$pendingOrders",
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "Preparing",
                      value: "$preparingOrders",
                      icon: Icons.local_fire_department,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _DashboardCard(
                      title: "Completed",
                      value: "$completedOrders",
                      icon: Icons.check_circle,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Responsibilities",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 12),
                    Text("• Create, read, update, and delete menu items"),
                    Text("• Control sauce and extra sambal options"),
                    Text("• Update satay availability"),
                    Text("• Monitor customer orders"),
                    Text("• Update order status"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

/* =========================
   MANAGE MENU CRUD
========================= */

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  void _showMenuForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    final nameController =
        TextEditingController(text: existingData?['name'] ?? '');
    final priceController =
        TextEditingController(text: existingData?['price']?.toString() ?? '');
    final imageController =
        TextEditingController(text: existingData?['imageUrl'] ?? '');
    final extraSambalPriceController = TextEditingController(
      text: existingData?['extraSambalPrice']?.toString() ?? '1.00',
    );

    final categories = ['Chicken', 'Beef', 'Lamb', 'Combo'];
    final tags = ['Popular', 'Bestseller', 'Hot', 'New', 'Combo'];
    final sauces = [
      'Sambal Kacang',
      'Kuah Kacang Pedas',
      'Sweet Peanut Sauce',
      'No Sauce',
    ];

    String selectedCategory = categories.contains(existingData?['category'])
        ? existingData!['category']
        : 'Chicken';

    String selectedTag =
        tags.contains(existingData?['tag']) ? existingData!['tag'] : 'Popular';

    String selectedSauce = sauces.contains(existingData?['sauce'])
        ? existingData!['sauce']
        : 'Sambal Kacang';

    bool isAvailable = existingData?['isAvailable'] ?? true;
    bool extraSambalAvailable = existingData?['extraSambalAvailable'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                docId == null ? "Add Menu Item" : "Edit Menu Item",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Item Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price per Set (RM)",
                          hintText: "Example: 15",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: "Image URL",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTag,
                        decoration: const InputDecoration(
                          labelText: "Tag / Label",
                          border: OutlineInputBorder(),
                        ),
                        items: tags.map((tag) {
                          return DropdownMenuItem(
                            value: tag,
                            child: Text(tag),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedTag = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedSauce,
                        decoration: const InputDecoration(
                          labelText: "Default Sauce",
                          border: OutlineInputBorder(),
                        ),
                        items: sauces.map((sauce) {
                          return DropdownMenuItem(
                            value: sauce,
                            child: Text(sauce),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedSauce = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        value: extraSambalAvailable,
                        title: const Text("Extra Sambal Available"),
                        subtitle:
                            const Text("Allow customer to add extra sambal"),
                        activeColor: Colors.deepOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => extraSambalAvailable = value);
                        },
                      ),
                      if (extraSambalAvailable) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: extraSambalPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Extra Sambal Price (RM)",
                            hintText: "Example: 1.00",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SwitchListTile(
                        value: isAvailable,
                        title: const Text("Menu Available"),
                        subtitle: const Text("Show this item to customers"),
                        activeColor: Colors.deepOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => isAvailable = value);
                        },
                      ),
                    ],
                  ),
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
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty ||
                        imageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please complete all required fields"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final data = <String, dynamic>{
                      'name': nameController.text.trim(),
                      'category': selectedCategory,
                      'price':
                          double.tryParse(priceController.text.trim()) ?? 0.0,
                      'imageUrl': imageController.text.trim(),
                      'tag': selectedTag,
                      'sauce': selectedSauce,
                      'extraSambalAvailable': extraSambalAvailable,
                      'extraSambalPrice': double.tryParse(
                            extraSambalPriceController.text.trim(),
                          ) ??
                          0.0,
                      'isAvailable': isAvailable,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    try {
                      if (docId == null) {
                        data['createdAt'] = FieldValue.serverTimestamp();
                        await FirebaseFirestore.instance
                            .collection('menu')
                            .add(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('menu')
                            .doc(docId)
                            .update(data);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              docId == null
                                  ? "Menu item added successfully"
                                  : "Menu item updated successfully",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(docId == null ? "ADD ITEM" : "UPDATE ITEM"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMenuItem(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Menu Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('menu').doc(docId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu item deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "Chicken":
        return Colors.orange;
      case "Beef":
        return Colors.brown;
      case "Lamb":
        return Colors.purple;
      case "Combo":
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Chicken":
        return Icons.egg_alt;
      case "Beef":
        return Icons.restaurant;
      case "Lamb":
        return Icons.kebab_dining;
      case "Combo":
        return Icons.fastfood;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Manage Menu CRUD",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        onPressed: () => _showMenuForm(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading menu: ${snapshot.error}"),
            );
          }

          final menuItems = snapshot.data?.docs ?? [];

          if (menuItems.isEmpty) {
            return const Center(
              child: Text(
                "No menu items yet.\nTap Add Item to create one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final doc = menuItems[index];
              final data = doc.data();

              final name = data['name'] ?? 'Unnamed';
              final category = data['category'] ?? '-';
              final price = ((data['price'] ?? 0) as num).toDouble();
              final available = data['isAvailable'] ?? true;
              final tag = data['tag'] ?? '';
              final sauce = data['sauce'] ?? 'No sauce';
              final imageUrl = data['imageUrl'] ?? '';
              final extraSambalAvailable =
                  data['extraSambalAvailable'] ?? false;
              final extraSambalPrice =
                  ((data['extraSambalPrice'] ?? 0) as num).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (imageUrl.toString().isNotEmpty)
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.orange.shade50,
                              child: const Center(
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.deepOrange,
                                  size: 45,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        color: Colors.orange.shade50,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.deepOrange,
                            size: 45,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _categoryColor(category).withOpacity(0.12),
                                child: Icon(
                                  _categoryIcon(category),
                                  color: _categoryColor(category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: available
                                      ? Colors.green.withOpacity(0.12)
                                      : Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  available ? "Available" : "Unavailable",
                                  style: TextStyle(
                                    color:
                                        available ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MiniChip(
                                label: category,
                                color: _categoryColor(category),
                              ),
                              if (tag.toString().isNotEmpty)
                                _MiniChip(
                                  label: tag,
                                  color: Colors.deepOrange,
                                ),
                              _MiniChip(
                                label: sauce,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "RM ${price.toStringAsFixed(2)} / set",
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            extraSambalAvailable
                                ? "Extra sambal available: RM ${extraSambalPrice.toStringAsFixed(2)}"
                                : "Extra sambal not available",
                            style: TextStyle(
                              color: extraSambalAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showMenuForm(
                                      context,
                                      docId: doc.id,
                                      existingData: data,
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _deleteMenuItem(context, doc.id);
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Delete"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/* =========================
   MANAGE ORDERS
========================= */

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  final List<String> statuses = const [
    "Pending",
    "Preparing",
    "Ready",
    "Completed",
    "Cancelled",
  ];

  Future<void> _updateStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Preparing":
        return Colors.blue;
      case "Ready":
        return Colors.green;
      case "Completed":
        return Colors.grey;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Manage Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("No customer orders yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data();

              final customerName = data['customerName'] ?? 'Customer';
              final phone = data['phone'] ?? '-';
              final address = data['address'] ?? '-';
              final status = data['status'] ?? 'Pending';
              final grandTotal = ((data['grandTotal'] ?? 0) as num).toDouble();
              final items = data['items'] as List<dynamic>? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Order #${doc.id.substring(0, 6)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Customer: $customerName"),
                    Text("Phone: $phone"),
                    Text("Address: $address"),
                    const Divider(height: 26),
                    ...items.map((item) {
                      final name = item['name'] ?? 'Item';
                      final sets = item['sets'] ?? 0;
                      final sticks = item['sticks'] ?? 0;
                      final total =
                          ((item['totalPrice'] ?? 0) as num).toDouble();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text("$name • $sets set ($sticks sticks)"),
                            ),
                            Text(
                              "RM ${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 26),
                    Text(
                      "Grand Total: RM ${grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Order Status",
                        border: OutlineInputBorder(),
                      ),
                      items: statuses.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == null) return;

                        await _updateStatus(doc.id, value);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Order updated to $value"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
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

/* =========================
   EDITABLE ADMIN ACCOUNT
========================= */

class AdminAccountPage extends StatefulWidget {
  const AdminAccountPage({super.key});

  @override
  State<AdminAccountPage> createState() => _AdminAccountPageState();
}

class _AdminAccountPageState extends State<AdminAccountPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isEditing = false;
  bool isSaving = false;

  Future<Map<String, dynamic>?> _getAdminData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': user.email,
      'role': 'admin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      isSaving = false;
      isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Admin profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _logoutAdmin() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(adminMode: true),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Admin Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
            icon: Icon(isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getAdminData(),
        builder: (context, snapshot) {
          final data = snapshot.data;

          final name = data?['name'] ?? 'Admin';
          final phone = data?['phone'] ?? 'Not provided';
          final role = data?['role'] ?? 'admin';

          if (!isEditing) {
            nameController.text = name;
            phoneController.text = phone;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE64A19), Color(0xFFFF7043)],
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
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.deepOrange,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        admin?.email ?? "Admin",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
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
                const SizedBox(height: 24),
                Container(
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
                      const Text(
                        "Admin Profile Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: nameController,
                        enabled: isEditing,
                        decoration: const InputDecoration(
                          labelText: "Admin Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        enabled: isEditing,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                          hintText: admin?.email ?? "No email",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Role",
                          prefixIcon: const Icon(Icons.verified_user),
                          border: const OutlineInputBorder(),
                          hintText: role.toString(),
                        ),
                      ),
                      if (isEditing) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save),
                            label: Text(
                              isSaving ? "SAVING..." : "SAVE PROFILE",
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _logoutAdmin,
                    icon: const Icon(Icons.logout),
                    label: const Text("LOGOUT ADMIN"),
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }
}
