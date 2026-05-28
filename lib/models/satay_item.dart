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
    this.sauces = const [
      'Sambal Kacang',
      'Sambal Kacang Pedas',
      'Sambal Kicap',
      'Tiada Sambal',
    ],
    this.maxSauceSelection = 2,
    this.extraSambalAvailable = false,
    this.extraSambalPrice = 0.0,
  });

  factory SatayItem.fromMap(String id, Map<String, dynamic> data) {
    final rawSauces = data['sauces'];

    List<String> sauceList = [
      'Sambal Kacang',
      'Sambal Kacang Pedas',
      'Sambal Kicap',
    ];

    if (rawSauces is List && rawSauces.isNotEmpty) {
      sauceList = rawSauces.map((e) => e.toString()).toList();
    }

    return SatayItem(
      id: id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      price: ((data['price'] ?? 0) as num).toDouble(),
      imageUrl: data['imageUrl']?.toString() ?? '',
      isAvailable: data['isAvailable'] ?? true,
      tag: data['tag']?.toString() ?? '',
      sauces: sauceList,
      maxSauceSelection: data['maxSauceSelection'] is int
          ? data['maxSauceSelection']
          : 2,
      extraSambalAvailable: data['extraSambalAvailable'] ?? false,
      extraSambalPrice: ((data['extraSambalPrice'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'tag': tag,
      'sauces': sauces,
      'maxSauceSelection': maxSauceSelection,
      'extraSambalAvailable': extraSambalAvailable,
      'extraSambalPrice': extraSambalPrice,
    };
  }
}