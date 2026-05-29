import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  String selectedFilter = "Day";

  DateTime _startDate() {
    final now = DateTime.now();

    if (selectedFilter == "Day") {
      return DateTime(now.year, now.month, now.day);
    } else if (selectedFilter == "Week") {
      return now.subtract(Duration(days: now.weekday - 1));
    } else if (selectedFilter == "Month") {
      return DateTime(now.year, now.month, 1);
    } else {
      return DateTime(now.year, 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu').snapshots(),
      builder: (context, menuSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, orderSnapshot) {
            final menuCount = menuSnapshot.data?.docs.length ?? 0;
            final orders = orderSnapshot.data?.docs ?? [];
            final startDate = _startDate();

            final filteredOrders = orders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'];
              if (timestamp is Timestamp) {
                return timestamp.toDate().isAfter(startDate);
              }
              return true;
            }).toList();

            final totalOrders = filteredOrders.length;
            final pendingOrders = filteredOrders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Pending';
            }).length;
            final completedOrders = filteredOrders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Completed';
            }).length;
            final totalSales = filteredOrders.fold<double>(0.0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + ((data['grandTotal'] ?? 0) as num).toDouble();
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Statistics",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedFilter,
                        items: const [
                          DropdownMenuItem(value: "Day", child: Text("Day")),
                          DropdownMenuItem(value: "Week", child: Text("Week")),
                          DropdownMenuItem(value: "Month", child: Text("Month")),
                          DropdownMenuItem(value: "Year", child: Text("Year")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedFilter = value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 700 ? 4 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.18,
                    children: [
                      _statCard("Menu Items", menuCount.toString(),
                          Icons.restaurant_menu, Colors.deepOrange),
                      _statCard("Orders", totalOrders.toString(),
                          Icons.receipt_long, Colors.blue),
                      _statCard("Pending", pendingOrders.toString(),
                          Icons.pending_actions, Colors.orange),
                      _statCard("Completed", completedOrders.toString(),
                          Icons.check_circle, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sales Performance",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Current filter: $selectedFilter",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "RM ${totalSales.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 34,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text("Total sales based on selected period"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 42),
          SizedBox(height: 16),
          Text(
            "Welcome back, Admin!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Monitor orders, menu, and SatayGo sales performance.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.deepOrange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions;
      case 'Preparing':
        return Icons.restaurant;
      case 'Ready':
        return Icons.check_circle;
      case 'Completed':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statuses = [
      'Pending',
      'Preparing',
      'Ready',
      'Completed',
      'Cancelled',
    ];

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final orders = snapshot.data?.docs ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "No orders yet 📦",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data();

            final currentStatus = data['status'] ?? 'Pending';
            final statusColor = _statusColor(currentStatus);
            final items = data['items'] as List<dynamic>? ?? [];
            final grandTotal = ((data['grandTotal'] ?? 0) as num).toDouble();

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.95),
                          Colors.deepOrange.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(_statusIcon(currentStatus),
                              color: statusColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Order #${doc.id.substring(0, 6)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          currentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.person, "Customer",
                            data['customerName'] ?? '-'),
                        _infoRow(Icons.phone, "Phone", data['phone'] ?? '-'),
                        _infoRow(Icons.access_time, "Pickup",
                            data['pickupTime'] ?? '-'),
                        _infoRow(Icons.payment, "Payment",
                            data['paymentMethod'] ?? '-'),
                        const Divider(height: 28),
                        const Text(
                          "Order Items",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...items.map((rawItem) {
                          final item = rawItem as Map<String, dynamic>? ?? {};
                          final name = item['name'] ?? 'Item';
                          final quantity =
                              ((item['quantity'] ?? 1) as num).toInt();
                          final sticks =
                              ((item['totalSticks'] ?? quantity * 10) as num)
                                  .toInt();
                          final totalPrice =
                              ((item['totalPrice'] ?? 0) as num).toDouble();
                          final sauces = item['selectedSauces'] is List
                              ? List<String>.from(item['selectedSauces'])
                              : <String>[];
                          final extraSambal = item['extraSambal'] == true;
                          final extraSambalPrice =
                              ((item['extraSambalPrice'] ?? 0) as num)
                                  .toDouble();

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F2),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    Colors.deepOrange.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text("Quantity: $quantity set"),
                                Text("Total sticks: $sticks sticks"),
                                if (sauces.isNotEmpty)
                                  Text("Sauce: ${sauces.join(', ')}"),
                                Text(
                                  extraSambal
                                      ? "Extra sambal: Yes (+RM ${extraSambalPrice.toStringAsFixed(2)})"
                                      : "Extra sambal: No",
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "RM ${totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Grand Total",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              "RM ${grandTotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          value: statuses.contains(currentStatus)
                              ? currentStatus
                              : 'Pending',
                          decoration: InputDecoration(
                            labelText: "Update Order Status",
                            filled: true,
                            fillColor: const Color(0xFFFFFAF5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: statuses
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Icon(_statusIcon(s),
                                          color: _statusColor(s)),
                                      const SizedBox(width: 8),
                                      Text(s),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            if (value == null) return;

                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(doc.id)
                                .set(
                              {
                                'status': value,
                                'updatedAt': FieldValue.serverTimestamp(),
                              },
                              SetOptions(merge: true),
                            );
                          },
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
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.deepOrange.shade50,
            child: Icon(icon, size: 17, color: Colors.deepOrange),
          ),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w900)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}