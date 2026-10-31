
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final int stock;
  final int price;
  final Timestamp createdAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.createdAt,
  });

  // Mengubah DocumentSnapshot dari Firestore menjadi objek ItemModel (Dart)
  factory ItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ItemModel(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      stock: (data['stock'] is num)
          ? (data['stock'] as num).toInt()
          : int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
      price: (data['price'] is num)
          ? (data['price'] as num).toInt()
          : int.tryParse(data['price']?.toString() ?? '0') ?? 0,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  // Mengubah objek ItemModel (Dart) menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock': stock,
      'price': price,
      'createdAt': createdAt,
    };
  }
}
