import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';
import 'satay_item.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String customerName;
  final String phone;
  final List<CartItem> items;
  final double totalPrice;
  final String status; // Pending, Preparing, Ready, Completed
  final DateTime timestamp;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      items: (map['items'] as List).map((item) {
        return CartItem(
          product: SatayItem(
            id: '',
            name: item['name'],
            category: '',
            price: (item['price'] as num).toDouble(),
            imageUrl: '',
            isAvailable: true,
            tag: item['tag'] ?? '',
          ),
          quantity: item['quantity'],
        );
      }).toList(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'phone': phone,
      'items': items
          .map((i) => {
                'name': i.product.name,
                'price': i.product.price,
                'quantity': i.quantity,
              })
          .toList(),
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
