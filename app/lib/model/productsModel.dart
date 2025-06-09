// lib/models/produto.dart
import 'dart:convert';

class Produto {
  final int? id;
  final String nome;
  final String categoria;
  final String barcode;
  final List<String> imagens;

  Produto({
    this.id,
    required this.nome,
    required this.categoria,
    required this.barcode,
    this.imagens = const [],
  });

  // Construtor para criar um Produto a partir de um JSON
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      // Mapeando "idProduct" do JSON para "id" no Flutter
      id: json['idProduct'] as int?,
      // Mapeando "name" do JSON para "nome" no Flutter
      // E garantindo que não seja nulo, usando ?? ''
      nome: (json['name'] as String?) ?? '',
      // Mapeando "category" do JSON para "categoria" no Flutter
      // E garantindo que não seja nulo, usando ?? ''
      categoria: (json['category'] as String?) ?? '',
      // No seu log não tem 'codigoBarras', mas vou manter a lógica
      // Se a API não envia 'codigoBarras', ele será uma string vazia
      barcode: (json['barcode'] as String?) ?? '',
      // Mapeando "image" do JSON para "imagens" no Flutter
      // E convertendo para uma lista de strings, se for uma única string, ou vazia se null
      imagens: [((json['image'] as String?) ?? '')], // Se a API retorna uma única string para 'image'
      // OU se a API retornar uma lista de strings para 'image':
      // imagens: List<String>.from(json['image'] ?? []),
    );
  }

  // Método para converter um Produto para um JSON (para enviar para a API)
  Map<String, dynamic> toJson() {
    return {
      'idProduct': id, // Ao enviar de volta, use o nome que a API espera
      'name': nome,
      'category': categoria,
      'barcode': barcode, // Mantenha se a API espera
      'image': imagens.isNotEmpty ? imagens.first : null, // Se a API espera uma única string 'image'
      // Ou se a API espera uma lista de 'image':
      // 'image': imagens,
    };
  }
}