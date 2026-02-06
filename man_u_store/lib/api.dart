import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';


class ApiService {
  // CHANGE THIS:
  // Android Emulator => http://10.0.2.2:8000
  // Real phone => http://YOUR_PC_IP:8000
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/products');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch products (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    final res = await http.delete(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to delete product (${res.statusCode})');
    }
  }

  // If you already have an update endpoint in FastAPI, use it like this:
  Future<void> updateProduct(Product p) async {
    final uri = Uri.parse('$baseUrl/products/${p.id}');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update product (${res.statusCode})');
    }
  }
}
