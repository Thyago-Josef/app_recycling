import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';

class SegundaPagina extends StatefulWidget {
  const SegundaPagina({super.key});

  @override
  State<SegundaPagina> createState() => _SegundaPaginaState();
}

class _SegundaPaginaState extends State<SegundaPagina> {
  String _filtroSelecionado = 'Todos';
  final List<Map<String, String>> _produtos = [
    {'nome': 'Shampoo Hidratante', 'categoria': 'Cabelo', 'codigo_barras': '12345'},
    {'nome': 'Condicionador Nutritivo', 'categoria': 'Cabelo', 'codigo_barras': '67890'},
    {'nome': 'Máscara Capilar Reconstrutora', 'categoria': 'Cabelo', 'codigo_barras': '11223'},
    {'nome': 'Base Líquida Matte', 'categoria': 'Maquiagem', 'codigo_barras': '44556'},
    {'nome': 'Corretivo Alta Cobertura', 'categoria': 'Maquiagem', 'codigo_barras': '77889'},
    {'nome': 'Paleta de Sombras Neutras', 'categoria': 'Maquiagem', 'codigo_barras': '99001'},
    {'nome': 'Hidratante Facial Oil-Free', 'categoria': 'Pele', 'codigo_barras': '22334'},
    {'nome': 'Protetor Solar FPS 50', 'categoria': 'Pele', 'codigo_barras': '55667'},
    {'nome': 'Sérum Vitamina C', 'categoria': 'Pele', 'codigo_barras': '88990'},
    {'nome': 'Óleo Capilar Reparador', 'categoria': 'Cabelo', 'codigo_barras': '33445'},
    {'nome': 'Blush Compacto Rosado', 'categoria': 'Maquiagem', 'codigo_barras': '66778'},
    {'nome': 'Tônico Facial Adstringente', 'categoria': 'Pele', 'codigo_barras': '99112'},
  ];

  List<Map<String, String>> get _produtosFiltrados {
    if (_filtroSelecionado == 'Todos') {
      return _produtos;
    } else {
      return _produtos
          .where((produto) => produto['categoria'] == _filtroSelecionado)
          .toList();
    }
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String barcodeScanRes = 'Aguardando leitura...';
  bool _isCameraActive = false;

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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        barcodeScanRes = scanData.code ?? '---';
      });

      if (barcodeScanRes != '---') {
        if (this.controller != null) {
          _pauseCamera();
        }

        final produtoEncontrado = _produtos.firstWhere(
              (produto) => produto['codigo_barras'] == barcodeScanRes,
          orElse: () => {},
        );

        if (produtoEncontrado.isNotEmpty) {
          _mostrarProdutoEncontrado(produtoEncontrado);
        } else {
          _mostrarOpcaoAdicionarProduto(barcodeScanRes);
        }
      }
    });
  }

  void _startCamera() {
    setState(() {
      _isCameraActive = true;
    });
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  void _stopCamera() {
    setState(() {
      _isCameraActive = false;
      barcodeScanRes = 'Aguardando leitura...';
    });
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  void _pauseCamera() {
    setState(() {
      _isCameraActive = false;
    });
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  void _resumeCameraSeAtiva() { // UMA DAS DEFINIÇÕES
    if (_isCameraActive && controller != null) {
      controller!.resumeCamera();
    }
  }

  void _mostrarProdutoEncontrado(Map<String, String> produto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Produto Encontrado'),
          content: Text('Nome: ${produto['nome']}\nCategoria: ${produto['categoria']}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeCameraSeAtiva();
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Produto Não Encontrado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Código de barras: $codigoBarras'),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
              ),
              DropdownButton<String>(
                value: categoriaSelecionada,
                items: <String>['Cabelo', 'Maquiagem', 'Pele']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    categoriaSelecionada = newValue;
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeCameraSeAtiva();
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                setState(() {
                  _produtos.add({
                    'nome': nomeController.text,
                    'categoria': categoriaSelecionada,
                    'codigo_barras': codigoBarras,
                  });
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produto adicionado!')),
                );
                _resumeCameraSeAtiva();
              },
            ),
          ],
        );
      },
    );
  }

  // A SEGUNDA DEFINIÇÃO (DUPLICADA) DE _resumeCameraSeAtiva() DEVE SER REMOVIDA

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
                final produto = _produtosFiltrados.elementAt(index);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(produto['nome']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _startCamera,
              child: const Text('Ler Código de Barras'),
            ),
          ),
          if (_isCameraActive)
            Expanded(
              flex: 1,
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
          if (_isCameraActive)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Código Lido: $barcodeScanRes'),
                  ElevatedButton(
                    onPressed: _stopCamera,
                    child: const Text('Parar Leitura'),
                  ),
                ],
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