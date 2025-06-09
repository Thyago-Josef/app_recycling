import 'dart:core';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http; // Não é mais necessário importar http aqui
import '../model/productsModel.dart'; // Importe seu modelo Produto
import '../service/productsService.dart'; // Importe seu serviço de API

class SegundaPagina extends StatefulWidget {
  final bool startWithScanner;
  const SegundaPagina({super.key, this.startWithScanner = false});

  @override
  State<SegundaPagina> createState() => _SegundaPaginaState();
}

class _SegundaPaginaState extends State<SegundaPagina> {
  String _filtroSelecionado = 'Todos';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String _lastScannedBarcode = 'Nenhum código lido';
  bool _isCameraActive = false;
  int _scannerMode = 0; // 0: Lista de produtos, 1: Câmera do scanner

  // INSTÂNCIA DO SEU SERVIÇO DE API
  final ProdutoApiService _produtoApiService = ProdutoApiService();

  // Lista de produtos que será preenchida pela API
  List<Produto> _produtos = [];
  // Future para gerenciar o estado da requisição de produtos
  late Future<List<Produto>> _futureProdutos;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid && controller != null) {
      controller!.pauseCamera();
    }
    if (_isCameraActive && controller != null) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    _futureProdutos = _produtoApiService.getProdutos(); // Inicia a requisição ao carregar a tela
    if (widget.startWithScanner) {
      _activateScannerMode();
    }
  }

  // Getter para produtos filtrados (agora da lista _produtos carregada da API)
  List<Produto> get _produtosFiltrados {
    if (_filtroSelecionado == 'Todos') {
      return _produtos;
    } else {
      return _produtos
          .where((produto) => produto.categoria == _filtroSelecionado)
          .toList();
    }

  }

  void _activateScannerMode() {
    setState(() {
      _scannerMode = 1; // Ativa o modo scanner
      _isCameraActive = true;
      _lastScannedBarcode = 'Aguardando leitura...'; // Reseta o texto
    });
  }

  void _deactivateScannerMode() {
    setState(() {
      _scannerMode = 0; // Desativa o modo scanner
      _isCameraActive = false;
      // Recarrega a lista de produtos quando sai do scanner
      _futureProdutos = _produtoApiService.getProdutos();
    });
    controller?.dispose(); // Dispõe o controller da câmera para liberar recursos
    controller = null;
  }

  void _handleScannedBarcode(String barcode) async {
    if (Navigator.of(context).canPop() && ModalRoute.of(context) is PopupRoute) {
      Navigator.of(context).pop();
    }

    try {
      final Produto? produtoEncontrado = await _produtoApiService.getProdutoByCodigoBarras(barcode);

      if (produtoEncontrado != null) {
        _mostrarProdutoEncontrado(produtoEncontrado);
      } else {
        _mostrarOpcaoAdicionarProduto(barcode);
      }
    } catch (e) {
      _mostrarOpcaoAdicionarProduto(barcode);
      // _mostrarErro('Erro ao buscar produto: $e');
      // _deactivateScannerMode(); // Volta para o modo de lista em caso de erro
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    if (controller != null) {
      controller.resumeCamera();
    }

    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera(); // Pausa a câmera para evitar múltiplos scans rápidos

      if (scanData.code != null) {
        String barcode = scanData.code!;
        setState(() {
          _lastScannedBarcode = barcode;
        });

        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        if (Navigator.of(context).canPop() && ModalRoute.of(context) is PopupRoute) {
          Navigator.of(context).pop();
        }

        _handleScannedBarcode(barcode);
      }
    });
  }

  void _mostrarProdutoEncontrado(Produto produto) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Produto Encontrado'),
          content: Text('Nome: ${produto.nome}\nCategoria: ${produto.categoria}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deactivateScannerMode();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetalhesProduto(Produto produto) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(produto.nome),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Categoria: ${produto.categoria}'),
                Text('Código de Barras: ${produto.barcode}'),
                if (produto.imagens.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text('Imagens:'),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: produto.imagens.length,
                      itemBuilder: (context, index) {
                        // Se as imagens forem URLs, use Image.network
                        // Se as imagens forem paths locais (temporariamente), use Image.file
                        // ATENÇÃO: Em um cenário real com API, as imagens seriam salvas em um serviço de cloud (S3, Firebase Storage)
                        // e você receberia URLs. Aqui, para simplicidade, mantemos File.
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(produto.imagens[index]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (produto.imagens.isEmpty)
                  const Text('Nenhuma imagem adicionada.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarOpcaoAdicionarProduto(String codigoBarras) {
    TextEditingController nomeController = TextEditingController();
    String categoriaSelecionada = 'Cabelo';
    List<File?> fotosTemporarias = [null, null, null];

    Future<void> _tirarFoto(int numeroFoto, StateSetter setStateDialog) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setStateDialog(() {
          fotosTemporarias[numeroFoto - 1] = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto $numeroFoto capturada!')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Produto Não Encontrado'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Código de barras: $codigoBarras'),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome do Produto'),
                    ),
                    DropdownButton<String>(
                      value: categoriaSelecionada,
                      items: <String>['Cabelo', 'Maquiagem', 'Pele', 'Perfumaria', 'Corpo']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            categoriaSelecionada = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Adicionar Fotos:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => _tirarFoto(1, setStateDialog),
                          child: Text(fotosTemporarias[0] != null ? 'Foto 1 (OK)' : 'Foto 1'),
                        ),
                        ElevatedButton(
                          onPressed: () => _tirarFoto(2, setStateDialog),
                          child: Text(fotosTemporarias[1] != null ? 'Foto 2 (OK)' : 'Foto 2'),
                        ),
                        ElevatedButton(
                          onPressed: () => _tirarFoto(3, setStateDialog),
                          child: Text(fotosTemporarias[2] != null ? 'Foto 3 (OK)' : 'Foto 3'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _deactivateScannerMode();
                  },
                ),
                TextButton(
                  child: const Text('Adicionar'),
                  onPressed: () async {
                    List<String> imagensPaths = [];
                    for (var foto in fotosTemporarias) {
                      if (foto != null) {
                        imagensPaths.add(foto.path);
                      }
                    }

                    final novoProduto = Produto(
                      nome: nomeController.text,
                      categoria: categoriaSelecionada,
                      barcode: codigoBarras,
                      imagens: imagensPaths,
                    );

                    try {
                      await _produtoApiService.createProduto(novoProduto);
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produto adicionado com sucesso!')),
                      );
                      setState(() {
                        _futureProdutos = _produtoApiService.getProdutos(); // Recarrega a lista
                      });
                      _deactivateScannerMode();
                    } catch (e) {
                      Navigator.of(dialogContext).pop();
                      _mostrarErro('Erro ao adicionar produto: $e');
                      _deactivateScannerMode();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos de Beleza'),
        actions: [
          IconButton(
            icon: Icon(_scannerMode == 0 ? Icons.qr_code_scanner : Icons.list),
            onPressed: () {
              if (_scannerMode == 0) {
                _activateScannerMode();
              } else {
                _deactivateScannerMode();
              }
            },
          ),
        ],
      ),
      body: _scannerMode == 1
          ? Stack(
        children: [
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Código Lido: $_lastScannedBarcode',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row( // Esta é a Row que estava causando o overflow
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Envolvendo cada botão com Expanded
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroSelecionado = 'Todos';
                      });
                    },
                    child: const Text('Todos'),
                  ),
                ),
                const SizedBox(width: 8), // Espaçamento entre os botões
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroSelecionado = 'Cabelo';
                      });
                    },
                    child: const Text('Cabelo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroSelecionado = 'Maquiagem';
                      });
                    },
                    child: const Text('Maquiagem'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroSelecionado = 'Pele';
                      });
                    },
                    child: const Text('Pele'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Produto>>(
              future: _futureProdutos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum produto encontrado.'));
                } else {
                  _produtos = snapshot.data!; // Atualiza a lista local de produtos
                  return ListView.builder(
                    itemCount: _produtosFiltrados.length,
                    itemBuilder: (context, index) {
                      final produto = _produtosFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(produto.nome),
                          subtitle: Text(produto.categoria),
                          trailing: const Icon(Icons.info),
                          onTap: () {
                            _mostrarDetalhesProduto(produto);
                          },
                        ),
                      );
                    },
                  );
                }
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
          } else if (index == 1) {
            _deactivateScannerMode();
          }
        },
      ),
    );
  }
}