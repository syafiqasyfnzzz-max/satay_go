import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/satay_item.dart';

final menuProvider = StreamProvider<List<SatayItem>>((ref) {
  return FirebaseFirestore.instance.collection('menu').snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return SatayItem.fromMap(doc.id, doc.data());
      }).toList();
    },
  );
});