import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/satay_item.dart';

final menuProvider = FutureProvider<List<SatayItem>>((ref) async {
  return [
    SatayItem(
      id: '1',
      name: 'Chicken Satay',
      category: 'Chicken',
      price: 15.00,
      imageUrl:
          'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?w=800',
      isAvailable: true,
      tag: 'Popular',
    ),
    SatayItem(
      id: '2',
      name: 'Beef Satay',
      category: 'Beef',
      price: 18.00,
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
      isAvailable: true,
      tag: 'Bestseller',
    ),
    SatayItem(
      id: '3',
      name: 'Lamb Satay',
      category: 'Lamb',
      price: 22.00,
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      isAvailable: true,
      tag: 'Hot',
    ),
    SatayItem(
      id: '4',
      name: 'Family Combo Set',
      category: 'Combo',
      price: 45.00,
      imageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800',
      isAvailable: true,
      tag: 'Combo',
    ),
  ];
});
