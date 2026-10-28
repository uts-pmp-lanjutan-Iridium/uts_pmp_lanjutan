class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double priceUsd;
  final int stock;
  final double rating;
  final String thumbnail;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priceUsd,
    required this.stock,
    required this.rating,
    required this.thumbnail,
    required this.images,
  });

  // Konversi harga USD dari DummyJSON ke estimasi harga pasar Rupiah (Rp)
  int get priceIdr => (priceUsd * 16000).round();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '-').toString(),
      description: (json['description'] ?? '-').toString(),
      category: (json['category'] ?? '-').toString(),
      priceUsd: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      thumbnail: (json['thumbnail'] ?? '').toString(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
