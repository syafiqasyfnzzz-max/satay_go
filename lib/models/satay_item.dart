class SatayItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final String tag;

  final List<String> sauces;
  final int maxSauceSelection;
  final bool extraSambalAvailable;
  final double extraSambalPrice;

  SatayItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.tag,
    this.sauces = const ['Sambal Kacang'],
    this.maxSauceSelection = 2,
    this.extraSambalAvailable = false,
    this.extraSambalPrice = 0.0,
  });

  factory SatayItem.fromMap(String id, Map<String, dynamic> data) {
    return SatayItem(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: ((data['price'] ?? 0) as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      tag: data['tag'] ?? '',
      sauces: data['sauces'] is List
          ? List<String>.from(data['sauces'])
          : ['Sambal Kacang'],
      maxSauceSelection: data['maxSauceSelection'] ?? 2,
      extraSambalAvailable: data['extraSambalAvailable'] ?? false,
      extraSambalPrice: ((data['extraSambalPrice'] ?? 0) as num).toDouble(),
    );
  }
}
