import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://192.168.0.7:8080';

  Future<List<Product>> fetchHighlightedProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/highlighted'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar produtos');
    }
  }
}
