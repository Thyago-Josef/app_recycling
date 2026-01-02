//
// import 'package:flutter/material.dart';
// import 'package:recycling_app/widgets/appBar.dart'; // Certifique-se de que este import está correto
// import '../widgets/InclinadoPainter.dart'; // Certifique-se de que este import está correto
//
// import 'products.dart'; // Certifique-se de que este import está correto
//
// // Mudado para StatefulWidget como uma boa prática e para gerenciar contexto de forma mais limpa
// class MyHomePage extends StatefulWidget {
//   final String title;
//
//   const MyHomePage({super.key, required this.title});
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     // Obtenha o tamanho da tela para posicionamento responsivo
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // Se você quiser uma AppBar, descomente a linha abaixo e o import de appBar.dart
//       // appBar: const MyCustomAppBar(
//       //   titleText: 'My Cosmetics App', // Você pode personalizar o título
//       // ),
//       body: Stack(
//         children: [
//           // 1. Pintor de fundo inclinado - sempre o primeiro no Stack para ficar no fundo
//           Positioned.fill(
//             child: CustomPaint(
//               painter: InclinadoPainter(), // Seu CustomPainter
//             ),
//           ),
//
//           // 2. Texto "Cosmetic" - Posicionado explicitamente para não bloquear outros elementos
//           Positioned(
//             top: screenHeight * 0.2, // Ajuste a posição superior conforme necessário
//             left: 0,
//             right: 0,
//             child: const Center(
//               child: Text(
//                 'Cosmetic',
//                 style: TextStyle(
//                   fontSize: 34.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // Cor do texto
//                 ),
//               ),
//             ),
//           ),
//
//           // 3. Botão "Ver Produtos" - Alinhado na parte inferior com um padding para espaçamento
//           Align(
//             alignment: Alignment.bottomCenter, // Alinha ao centro inferior do Stack
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 100.0), // Ajuste o padding inferior para posicionar o botão
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Navega para a SegundaPagina no modo padrão
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SegundaPagina()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.pinkAccent,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   elevation: 5,
//                 ),
//                 child: const Text(
//                   'Ver Produtos',
//                   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//
//           // 4. Botão da Câmera (Círculo) - Posicionado e garantindo que seja clicável
//           Positioned(
//             left: 0,
//             right: 0,
//             // Ajustado para posicionar o círculo um pouco acima do botão "Ver Produtos"
//             bottom: screenHeight * 0.35,
//             child: GestureDetector(
//               onTap: () {
//                 // Navega para a SegundaPagina, iniciando no modo scanner
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SegundaPagina(startWithScanner: true),
//                   ),
//                 );
//               },
//               child: Center(
//                 child: Container(
//                   width: 100.0,
//                   height: 100.0, // Altura ajustada para ser um círculo perfeito
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.pinkAccent.withOpacity(0.8),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.pinkAccent,
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.camera_alt,
//                     size: 40.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }