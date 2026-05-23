import 'package:satay_master_pro/models/satay_item.dart';

class CartItem {
  final SatayItem product;
  final int quantity;
  final List<String> selectedSauces;
  final bool extraSambal;
  final double extraSambalPrice;

  CartItem({
    required this.product,
    required this.quantity,
    this.selectedSauces = const [],
    this.extraSambal = false,
    this.extraSambalPrice = 0.0,
  });

  int get totalSticks => quantity * 10;

  double get totalPrice {
    final sambalTotal = extraSambal ? extraSambalPrice * quantity : 0.0;
    return (product.price * quantity) + sambalTotal;
  }

  CartItem copyWith({
    SatayItem? product,
    int? quantity,
    List<String>? selectedSauces,
    bool? extraSambal,
    double? extraSambalPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSauces: selectedSauces ?? this.selectedSauces,
      extraSambal: extraSambal ?? this.extraSambal,
      extraSambalPrice: extraSambalPrice ?? this.extraSambalPrice,
    );
  }

  // Convert a CartItem into a map.
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'quantity': quantity,
      'pricePerSet': product.price,
      'totalPrice': totalPrice,
      'selectedSauces': selectedSauces,
      'extraSambal': extraSambal,
      'extraSambalPrice': extraSambalPrice,
      'totalSticks': totalSticks,
    };
  }

  // Create a CartItem from a map.
  factory CartItem.fromMap(Map<String, dynamic> map) {
    // Reconstruct a simplified SatayItem for display in order history etc.
    final product = SatayItem(
      id: map['productId'],
      name: map['name'],
      price: (map['pricePerSet'] as num).toDouble(),
      category: '', // Not stored in order item
      imageUrl: '', // Not stored in order item
      isAvailable: true, // Assume available for historical orders
      tag: '', // Not stored in order item
    );

    return CartItem(
      product: product,
      quantity: map['quantity'],
      selectedSauces: List<String>.from(map['selectedSauces']),
      extraSambal: map['extraSambal'],
      extraSambalPrice: (map['extraSambalPrice'] as num).toDouble(),
    );
  }
}
