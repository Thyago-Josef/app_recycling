import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/productsService.dart';

class HomeController extends ChangeNotifier {
  final ProductsService _service = ProductsService();

  List<Product> products = [];
  bool loading = false;
  String? error;

  // --- NOVOS GETTERS E MÉTODOS PARA COMPATIBILIDADE ---

  // A HomeScreen chama 'loadAll', então criamos esse apelido para 'fetchProdutos'
  Future<void> loadAll() => fetchProdutos();

  // A HomeScreen busca por estes nomes, então redirecionamos para as variáveis corretas
  bool get isLoadingProducts => loading;
  List<Product> get highlightedProducts => products;

  // Como você ainda não tem um sistema de reviews, criamos listas vazias para não dar erro
  bool get isLoadingReviews => false;
  List<dynamic> get latestReviews => [];

  /// 🔄 Carrega todos os produtos ----------------------
  Future<void> fetchProdutos() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      products = await _service.getProdutos();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ➕ Cria um novo produto
  Future<void> addProduto(Product product) async {
    try {
      final novo = await _service.createProduto(product);
      products.add(novo);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// ✏️ Atualiza um produto existente
  Future<void> updateProduto(Product product) async {
    try {
      final atualizado = await _service.updateProduto(product);
      final index = products.indexWhere((p) => p.id == atualizado.id);
      if (index != -1) {
        products[index] = atualizado;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// ❌ Deleta um produto
  Future<void> deleteProduto(int id) async {
    try {
      await _service.deleteProduto(id);
      products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// 📷 Busca produto pelo código de barras
  Future<Product?> buscarPorCodigo(String codigo) async {
    try {
      return await _service.getProdutoByCodigoBarras(codigo);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }


}
