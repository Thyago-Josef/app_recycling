import 'package:flutter/material.dart';
import 'products.dart'; // Certifique-se de importar a SegundaPagina

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Olá, Mundo Flutter!',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Esta é uma página inicial básica.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 30.0), // Adiciona um espaço antes do botão
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SegundaPagina()),
                );
              },
              child: const Text('Ver Produtos'),
            ),
          ],
        ),
      ),
    );
  }
}