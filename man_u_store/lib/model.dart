class Product {
  final String id;
  final String name;
  final String? nameLc;
  final String category;
  final String descriptions;
  final double price;
  final int stockQuantity;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    this.nameLc,
    required this.category,
    required this.descriptions,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = (json['image_url'] ?? '') as String;
    String fixedImageUrl = rawImageUrl.replaceAll('localhost', '192.168.0.198');
    if (fixedImageUrl.startsWith('/')) {
      fixedImageUrl = 'http://192.168.0.198:8000$fixedImageUrl';
    }

    return Product(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      nameLc: json['name_lc'] as String?,
      category: (json['category'] ?? '') as String,
      descriptions: (json['descriptions'] ?? '') as String,
      price: json['price'] is String ? double.parse(json['price']) : (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] is String ? int.parse(json['stock_quantity']) : (json['stock_quantity'] as num).toInt(),
      imageUrl: fixedImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "name_lc": nameLc,
      "category": category,
      "descriptions": descriptions,
      "price": price,
      "stock_quantity": stockQuantity,
      "image_url": imageUrl,
    };
  }
}
