import 'satay_item.dart';

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
}
