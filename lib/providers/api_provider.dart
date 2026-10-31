
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import 'item_provider.dart'; // Menggunakan enum ViewState { loading, loaded, error, empty }

class ApiProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  ViewState _state = ViewState.loading;
  String _errorMessage = '';

  List<ProductModel> get products => _products;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;

  ApiProvider() {
    fetchProducts();
  }

  // Memanggil Future dari ApiService dan mengatur perubahan ViewState
  Future<void> fetchProducts() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _apiService.fetchMarketProducts();
      _products = result;

      if (_products.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
