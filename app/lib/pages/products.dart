import 'dart:core';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importe o plugin

class SegundaPagina extends StatefulWidget {
  const SegundaPagina({super.key, this.barcode, required this.produtos});
  final String? barcode;
  final List<Map<String, dynamic>> produtos; // Recebe a lista de produtos

  @override
  State<SegundaPagina> createState() => _SegundaPaginaState();
}

class _SegundaPaginaState extends State<SegundaPagina> {
  String _filtroSelecionado = 'Todos';


  List<Map<String, dynamic>> get _produtosFiltrados {
    if (_filtroSelecionado == 'Todos') {
      return widget.produtos; // Usa a lista recebida
    } else {
      return widget.produtos
          .where((produto) => produto['categoria'] == _filtroSelecionado)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      // Use o contexto armazenado em MyHomePage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarProdutoEncontrado();
      });
    }
  }

  void _mostrarProdutoEncontrado() {
    if (context != null) {
      final produto = widget.produtos.firstWhere(
            (element) => element['codigo_barras'] == widget.barcode,
        orElse: () => {
          'nome': 'Produto não encontrado',
          'categoria': '',
          'codigo_barras': '',
          'notFound': true, // Adiciona um marcador para indicar que não foi encontrado
        }, // Garante um retorno
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Produto Encontrado'),
            content: produto['notFound'] == true
                ? const Text('Produto não encontrado. Deseja cadastrar?')
                : Text('Nome: ${produto['nome']}\nCategoria: ${produto['categoria']}'),
            actions: <Widget>[
              TextButton(
                child: const Text('Não'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (produto['notFound'] == true) // Mostrar apenas se o produto não for encontrado
                TextButton(
                  child: const Text('Sim'),
                  onPressed: () {
                    // Navegar para a página de cadastro de produtos
                    Navigator.of(context).pop(); // Fechar o diálogo

                    // Envia para a página de cadastro e já passa o código de barras
                    showDialog(
                      context: context,
                      builder: (context) => CadastroProdutoDialog(
                        barcode: widget.barcode ??
                            '', // Passa o código de barras para a página de cadastro
                        onSave: (novoProduto) {
                          // Lógica para salvar o produto no banco de dados
                          setState(() {
                            widget.produtos.add(novoProduto);
                          });
                        },
                        onCancel: () {},
                      ),
                    );
                  },
                ),
              if (produto['notFound'] != true)
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos de Beleza'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroSelecionado = 'Todos';
                    });
                  },
                  child: const Text('Todos'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroSelecionado = 'Cabelo';
                    });
                  },
                  child: const Text('Cabelo'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroSelecionado = 'Maquiagem';
                    });
                  },
                  child: const Text('Maquiagem'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroSelecionado = 'Pele';
                    });
                  },
                  child: const Text('Pele'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = _produtosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(produto['nome'] ?? 'Nome indisponível'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produtos',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

// Página de cadastro de produtos (exemplo)
class CadastroProdutoDialog extends StatefulWidget {
  final String barcode;
  final Function(Map<String, dynamic>) onSave; // Modificado para receber um Map
  final VoidCallback onCancel;
  const CadastroProdutoDialog(
      {super.key, required this.barcode, required this.onSave, required this.onCancel});

  @override
  _CadastroProdutoDialogState createState() => _CadastroProdutoDialogState();
}

class _CadastroProdutoDialogState extends State<CadastroProdutoDialog> {
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar Produto'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código de Barras: ${widget.barcode}'),
            // Adicione campos para nome, categoria, etc.
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
            ),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            TextField(
              controller: _precoController,
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // Lógica para salvar o produto no banco de dados
            // Se isNewProduct for true, você pode adicionar uma lógica específica aqui
            // Navigator.of(context).pop(); // Retorna à página anterior
            // Aqui, você chamaria o onSave callback para notificar a MyHomePage
            // que os dados foram salvos.  Você também pode passar os dados, se necessário.
            final nome = _nomeController.text;
            final categoria = _categoriaController.text;
            final preco = _precoController.text;
            if (nome.isNotEmpty && categoria.isNotEmpty && preco.isNotEmpty) {
              // Validação dos dados
              final novoProduto = {  // Cria um Map com os dados do produto
                'nome': nome,
                'categoria': categoria,
                'codigo_barras': widget.barcode,
                'preco': preco,
                'imagens': <String>[], // Pode adicionar lógica para imagens depois
              };
              widget.onSave(novoProduto); // Chama o callback onSave e passa o Map
              Navigator.of(context).pop();
            } else {
              // Exibir mensagem de erro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, preencha todos os campos.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}