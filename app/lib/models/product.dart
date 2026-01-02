// lib/models/produto.dart
import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final String category;
  final String brand;
  final String barcode;
 // final List<String> imagens;
  final String imageUrl;
  final double rating;


  Product({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.barcode,
    //this.imagens = const [],
    required this.imageUrl,
    required this.rating,
  });

  // Construtor para criar um Produto a partir de um JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Mapeando "idProduct" do JSON para "id" no Flutter
      id: json['idProduct'] as int?,
      // Mapeando "name" do JSON para "nome" no Flutter
      // E garantindo que não seja nulo, usando ?? ''
      name: (json['name'] as String?) ?? '',
      // Mapeando "category" do JSON para "categoria" no Flutter
      // E garantindo que não seja nulo, usando ?? ''
      category: (json['category'] as String?) ?? '',

      brand: (json['brand'] as String?) ?? '',
      // No seu log não tem 'codigoBarras', mas vou manter a lógica
      // Se a API não envia 'codigoBarras', ele será uma string vazia
      barcode: (json['barcode'] as String?) ?? '',
      // Mapeando "image" do JSON para "imagens" no Flutter
      // E convertendo para uma lista de strings, se for uma única string, ou vazia se null
    //  imagens: [((json['image'] as String?) ?? '')], // Se a API retorna uma única string para 'image'
      // OU se a API retornar uma lista de strings para 'image':
      // imagens: List<String>.from(json['image'] ?? []),
      imageUrl: (json['imageUrl'] as String?) ?? '',

      rating: (json['rating'] as double),
    );
  }

  // Método para converter um Produto para um JSON (para enviar para a API)
  Map<String, dynamic> toJson() {
    return {
      'idProduct': id, // Ao enviar de volta, use o nome que a API espera
      'name': name,
      'brand' : brand,
      'category': category,
      'barcode': barcode, // Mantenha se a API espera
     // 'image': imagens.isNotEmpty ? imagens.first : null, // Se a API espera uma única string 'image'
      // Ou se a API espera uma lista de 'image':
      // 'image': imagens,
      'imageUrl' : imageUrl,
      'rating' : rating,
    };
  }
}