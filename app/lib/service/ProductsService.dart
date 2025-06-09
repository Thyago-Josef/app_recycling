// lib/services/produto_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/productsModel.dart'; // Ajuste o caminho

class ProdutoApiService {
  // Ajuste este URL para o endereço da sua API Java
  // Lembre-se: para emuladores Android, use '10.0.2.2' para acessar o localhost da sua máquina
  // Para emuladores iOS ou web, 'localhost' geralmente funciona
  final String _baseUrl = 'http://192.168.0.7:8080/products'; // Exemplo para Spring Boot

  // Cabeçalhos comuns para requisições JSON
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Método para buscar todos os produtos
  Future<List<Produto>> getProdutos() async {
    try {
      print('DEBUG: Tentando buscar produtos da URL: $_baseUrl'); // Debug: URL
      final response = await http.get(Uri.parse(_baseUrl + "/all"));

      print('DEBUG: Status Code da resposta: ${response.statusCode}'); // Debug: Status
      print('DEBUG: Corpo da resposta: ${response.body}'); // Debug: Corpo da resposta

      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return List<Produto>.from(jsonResponse.map((model) => Produto.fromJson(model)));
      } else {
        throw Exception('Falha ao carregar produtos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      throw Exception('Erro de conexão ou servidor ao buscar produtos: $e');
    }
  }

  // Método para buscar um produto pelo código de barras
  Future<Produto?> getProdutoByCodigoBarras(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/barcode/$barcode')); // Supondo um endpoint '/barcode/{codigoBarras}'

      if (response.statusCode == 200) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        return null; // Produto não encontrado
      } else {
        throw Exception('Falha ao buscar produto por código de barras: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar produto por código de barras: $e');
      throw Exception('Erro de conexão ou servidor ao buscar produto: $e');
    }
  }

  // Método para criar um novo produto
  Future<Produto> createProduto(Produto produto) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl + "/create"),
        headers: _headers,
        body: jsonEncode(produto.toJson()),
      );

      if (response.statusCode == 201) { // 201 Created é o status comum para criação
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Falha ao criar produto: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao criar produto: $e');
      throw Exception('Erro de conexão ou servidor ao criar produto: $e');
    }
  }

  // Método para atualizar um produto
  Future<Produto> updateProduto(Produto produto) async {
    if (produto.id == null) {
      throw Exception('ID do produto é necessário para atualização.');
    }
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${produto.id}'),
        headers: _headers,
        body: jsonEncode(produto.toJson()),
      );

      if (response.statusCode == 200) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Falha ao atualizar produto: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      throw Exception('Erro de conexão ou servidor ao atualizar produto: $e');
    }
  }

  // Método para deletar um produto
  Future<void> deleteProduto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 204) { // 204 No Content é o status comum para exclusão bem-sucedida
        print('Produto $id deletado com sucesso.');
      } else {
        throw Exception('Falha ao deletar produto: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao deletar produto: $e');
      throw Exception('Erro de conexão ou servidor ao deletar produto: $e');
    }
  }
}