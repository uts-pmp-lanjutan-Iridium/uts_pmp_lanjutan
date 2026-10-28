import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';

class FirestoreService {
  // Menggunakan CollectionReference ke collection 'items' sesuai syarat soal
  final CollectionReference<Map<String, dynamic>> _itemsRef = FirebaseFirestore
      .instance
      .collection('items');

  // 1. STREAM (Read real-time): Menggunakan snapshots() (Stream)
  // Tanpa .orderBy() di query Firestore sesuai aturan P05 (sorting dilakukan di Dart)
  Stream<List<ItemModel>> streamItems() {
    return _itemsRef.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc))
          .toList();

      // Sorting di sisi client (Dart) berdasarkan createdAt terbaru di atas
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // 2. GET (Read sekali jalan dengan Future - memenuhi syarat Future P01)
  Future<List<ItemModel>> getItemsOnce() async {
    final snapshot = await _itemsRef.get();
    final items = snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  // 3. ADD (Create): Menambah barang baru ke collection 'items'
  Future<void> addItem({
    required String name,
    required int stock,
    required int price,
  }) async {
    final newItem = ItemModel(
      id: '',
      name: name,
      stock: stock,
      price: price,
      createdAt: Timestamp.now(),
    );
    await _itemsRef.add(newItem.toMap());
  }

  // 4. UPDATE: Mengubah data barang berdasarkan document ID
  Future<void> updateItem({
    required String id,
    required String name,
    required int stock,
    required int price,
  }) async {
    await _itemsRef.doc(id).update({
      'name': name,
      'stock': stock,
      'price': price,
      'createdAt': Timestamp.now(),
    });
  }

  // 5. DELETE: Menghapus barang berdasarkan document ID
  Future<void> deleteItem(String id) async {
    await _itemsRef.doc(id).delete();
  }
}
