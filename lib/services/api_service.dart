import 'package:dio/dio.dart';

import '../models/product_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Menggunakan Future + Dio GET untuk mengambil referensi harga pasar (DummyJSON Products)
  Future<List<ProductModel>> fetchMarketProducts() async {
    try {
      // Mengambil produk kategori groceries (sembako/kebutuhan warung)
      final response = await _dio.get('/products/category/groceries');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> productList = response.data['products'] ?? [];
        return productList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat data pasar (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.message ??
            'Terjadi gangguan koneksi saat menghubungi server DummyJSON.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
