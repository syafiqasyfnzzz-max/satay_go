import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:satay_master_pro/models/cart_item.dart';

class OrderModel {
  String? orderId;
  final String userId;
  final String? customerEmail;
  final String customerName;
  final String phone;
  final String pickupTime;
  final String paymentMethod;
  final List<CartItem> items;
  final double subtotal;
  final double serviceFee;
  final double grandTotal;
  final String status;
  final DateTime? timestamp;

  OrderModel({
    this.orderId,
    required this.userId,
    this.customerEmail,
    required this.customerName,
    required this.phone,
    required this.pickupTime,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.grandTotal,
    this.status = 'Pending',
    this.timestamp,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      customerEmail: map['customerEmail'],
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      pickupTime: map['pickupTime'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      serviceFee: (map['serviceFee'] as num).toDouble(),
      grandTotal: (map['grandTotal'] as num).toDouble(),
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'phone': phone,
      'pickupTime': pickupTime,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'serviceFee': serviceFee,
      'grandTotal': grandTotal,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
