
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';

// Enum ViewState wajib sesuai syarat P03/P05 di soal UTS
enum ViewState { loading, loaded, error, empty }

class ItemProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ItemModel> _items = [];
  ViewState _state = ViewState.loading;
  String _errorMessage = '';

  // StreamSubscription disimpan agar wajib bisa di-cancel saat dispose()
  StreamSubscription<List<ItemModel>>? _itemsSubscription;

  // Getter untuk diakses oleh UI (HomeScreen)
  List<ItemModel> get items => _items;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;

  ItemProvider() {
    listenToItems();
  }

  // Mendengarkan perubahan data barang secara real-time (Stream)
  void listenToItems() {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    // Batalkan subscription lama jika ada (misal saat tombol Retry ditekan)
    _itemsSubscription?.cancel();

    _itemsSubscription = _firestoreService.streamItems().listen(
      (data) {
        _items = data;
        if (_items.isEmpty) {
          _state = ViewState.empty;
        } else {
          _state = ViewState.loaded;
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Gagal memuat data inventaris: $error';
        _state = ViewState.error;
        notifyListeners();
      },
    );
  }

  // Operasi Tambah Barang
  Future<void> addItem({
    required String name,
    required int stock,
    required int price,
  }) async {
    await _firestoreService.addItem(name: name, stock: stock, price: price);
  }

  // Operasi Edit/Update Barang
  Future<void> updateItem({
    required String id,
    required String name,
    required int stock,
    required int price,
  }) async {
    await _firestoreService.updateItem(
      id: id,
      name: name,
      stock: stock,
      price: price,
    );
  }

  // Operasi Hapus Barang
  Future<void> deleteItem(String id) async {
    await _firestoreService.deleteItem(id);
  }

  // Syarat Wajib UTS: melakukan dispose subscription agar tidak memory leak
  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }
}
