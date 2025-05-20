import 'package:flutter/material.dart';
import 'products.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart'; // Importe o scanner

class MyHomePage extends StatefulWidget { // Alterado para StatefulWidget
  const MyHomePage({super.key, required String title});

  @override
  _MyHomePageState createState() => _MyHomePageState(); // Adicione o createState
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Chave para o QRView
  QRViewController? controller;
  String barcodeScanRes = 'Aguardando leitura...';
  bool _isCameraActive = false;
  bool _isNavigating = false; // Flag para controlar a navegação
  BuildContext? dialogContext; // Armazena o contexto para exibir diálogos
  final List<Map<String, dynamic>> _produtos = [    // Lista de produtos movida para cá
    {'nome': 'Shampoo Hidratante', 'categoria': 'Cabelo', 'codigo_barras': '12345', 'imagens': <String>[]},
    {'nome': 'Condicionador Nutritivo', 'categoria': 'Cabelo', 'codigo_barras': '67890', 'imagens': <String>[]},
    {'nome': 'Máscara Capilar Reconstrutora', 'categoria': 'Cabelo', 'codigo_barras': '11223', 'imagens': <String>[]},
    {'nome': 'Base Líquida Matte', 'categoria': 'Maquiagem', 'codigo_barras': '44556', 'imagens': <String>[]},
    {'nome': 'Corretivo Alta Cobertura', 'categoria': 'Maquiagem', 'codigo_barras': '77889', 'imagens': <String>[]},
    {'nome': 'Paleta de Sombras Neutras', 'categoria': 'Maquiagem', 'codigo_barras': '99001', 'imagens': <String>[]},
    {'nome': 'Hidratante Facial Oil-Free', 'categoria': 'Pele', 'codigo_barras': '22334', 'imagens': <String>[]},
    {'nome': 'Protetor Solar FPS 50', 'categoria': 'Pele', 'codigo_barras': '55667', 'imagens': <String>[]},
    {'nome': 'Sérum Vitamina C', 'categoria': 'Pele', 'codigo_barras': '88990', 'imagens': <String>[]},
  ];

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Função para iniciar a câmera
  void _startCamera() {
    setState(() {
      _isCameraActive = true;
    });
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  // Função para parar a câmera
  void _stopCamera() async {
    setState(() {
      _isCameraActive = false;
      barcodeScanRes = 'Aguardando leitura...';
    });
    if (controller != null) {
      await controller!.pauseCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (_isNavigating) return; // Retorna se já estiver navegando
      if (scanData.code != null) {
        setState(() {
          barcodeScanRes = scanData.code!;
        });
        _isNavigating = true; // Define a flag antes de navegar
        _stopCamera(); // Para a câmera após a leitura

        // Navega para a página de resultados ou faz o que for necessário com o código lido.
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CadastroProdutoPage(
        //       barcode: barcodeScanRes,
        //       isNewProduct: true, // Indica que é um novo produto
        //     ),
        //   ),
        // ).then((_) {
        //   _isNavigating = false; // Reseta a flag após a navegação
        // });
        // Mostrar o diálogo de cadastro diretamente
        showDialog(
          context: context,
          builder: (context) => CadastroProdutoDialog(
            barcode: barcodeScanRes,
            onSave: (novoProduto) { // Recebe o novo produto
              _isNavigating = false;
              setState(() {
                _produtos.add(novoProduto); // Adiciona à lista
              });
              Navigator.of(context).pop();
            },
            onCancel: () {
              _isNavigating = false;
              Navigator.of(context).pop();
            },
          ),
        ).then((_) {
          _isNavigating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Armazena o contexto aqui
    dialogContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cosmetic',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
        elevation: 2,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Cosmetic',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Tudo para cosméticos',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 80.0),
              ],
            ),
          ),
          // Botão da câmera
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: GestureDetector(
              onTap: () {
                if (_isCameraActive) {
                  _stopCamera();
                } else {
                  _startCamera();
                }
              },
              child: Center(
                child: Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pinkAccent.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isCameraActive ? Icons.cancel : Icons.camera_alt, // Mostrar ícone de cancelar ou câmera
                    size: 50.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Botão "Ver Produtos" na parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  SegundaPagina(produtos: _produtos) ), // Passa a lista
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Ver Produtos',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (_isCameraActive) // Mostrar a câmera se _isCameraActive for verdadeiro
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      QRView(
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
                    ],
                  ),
                ),
              ),
            ),
          if (_isCameraActive) // Botão de fechar a câmera
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _stopCamera,
                child: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }
}