// lib/shop/sticker_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Sticker {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  Sticker({required this.id, required this.name, required this.price, required this.imageUrl});

  factory Sticker.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Sticker(
      id: doc.id,
      name: data['name'],
      price: data['price'],
      imageUrl: data['imageUrl'],
    );
  }
}
