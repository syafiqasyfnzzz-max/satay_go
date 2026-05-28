// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading orders: ${snapshot.error}"),
                  );
                }

                final orders = snapshot.data?.docs ?? [];

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      "No orders yet 📦",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data();

                    final status = data['status'] ?? 'Pending';
                    final grandTotal =
                        ((data['grandTotal'] ?? 0) as num).toDouble();

                    final subtotal =
                        ((data['subtotal'] ?? grandTotal) as num).toDouble();

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
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(width: 8),
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
                                  borderRadius: BorderRadius.circular(20),
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

                          const SizedBox(height: 12),
                          Text("Pickup Time: ${data['pickupTime'] ?? '-'}"),

                          const Divider(height: 28),

                          const Text(
                            "Order Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ...items.map((rawItem) {
                            final item =
                                rawItem as Map<String, dynamic>? ?? {};

                            final name = item['name'] ?? 'Item';

                            final quantity =
                                ((item['quantity'] ?? item['sets'] ?? 1)
                                        as num)
                                    .toInt();

                            final safeQuantity =
                                quantity <= 0 ? 1 : quantity;

                            final sticks =
                                ((item['totalSticks'] ??
                                            item['sticks'] ??
                                            safeQuantity * 10)
                                        as num)
                                    .toInt();

                            final safeSticks =
                                sticks <= 0 ? safeQuantity * 10 : sticks;

                            final pricePerSet =
                                ((item['pricePerSet'] ?? 0) as num).toDouble();

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
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.deepOrange.withOpacity(0.12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Quantity: $safeQuantity set",
                                  ),
                                  Text(
                                    "Total sticks: $safeSticks sticks",
                                  ),
                                  if (pricePerSet > 0)
                                    Text(
                                      "Price per set: RM ${pricePerSet.toStringAsFixed(2)}",
                                    ),
                                  if (sauces.isNotEmpty)
                                    Text(
                                      "Sauce: ${sauces.join(', ')}",
                                    ),
                                  Text(
                                    extraSambal
                                        ? "Extra sambal: Yes (+RM ${extraSambalPrice.toStringAsFixed(2)})"
                                        : "Extra sambal: No",
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Item total: RM ${totalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w900,
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
                                "Subtotal",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "RM ${subtotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Grand Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "RM ${grandTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Payment Method: ${data['paymentMethod'] ?? '-'}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
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