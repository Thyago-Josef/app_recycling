import 'package:flutter/material.dart';


class InclinadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      //..color = Colors.red // Cor do traço
      ..color = Colors.pinkAccent.withOpacity(0.15) // Cor de preenchimento (mais suave)
      ..style = PaintingStyle.fill; // Importante: define o estilo como preench
      //..strokeWidth = 5.0 // Espessura do traço
      //..strokeCap = StrokeCap.round; // Formato das extremidades do traço

    // Cria um Path para a forma a ser preenchida
    final path = Path();

    // Começa no canto superior esquerdo (0,0)
    path.moveTo(0, 0);

    // Linha até o canto superior direito (size.width, 0)
    path.lineTo(size.width, 0);

    // A linha inclinada que definirá o "corte"
    // Este ponto de chegada define a inclinação do "corte"
    // Exemplo: 80% da largura na parte de baixo, 20% da altura a partir do topo
    path.lineTo(size.width, size.height * 0.4); // Ponto superior direito da linha inclinada
    path.lineTo(0, size.height * 0.3);          // Ponto inferior esquerdo da linha inclinada

    // Fecha o Path para formar uma área fechada (volta para 0,0)
    path.close();

    // Desenha e preenche o Path
    canvas.drawPath(path, paint);

    // Opcional: Se você ainda quiser uma linha de traço na borda,
    // você pode desenhá-la separadamente com um paint diferente:
    // final strokePaint = Paint()
    //   ..color = Colors.pinkAccent // Cor do traço da borda
    //   ..strokeWidth = 2.0
    //   ..style = PaintingStyle.stroke;
    // canvas.drawPath(path, strokePaint);

    // Calcula os pontos de início e fim para um traço atravessado no meio
    // Este exemplo desenha uma linha diagonal de cima à esquerda para baixo à direita.
    // Você pode ajustar esses pontos para mudar a inclinação e a posição.
    // Ponto de início (por exemplo, 20% da largura a partir da esquerda, 20% da altura a partir do topo)
    // final Offset startPoint = Offset(size.width * 0.0, size.height * 0.2);
    //
    // // Ponto de fim (por exemplo, 80% da largura a partir da esquerda, 80% da altura a partir do topo)
    // final Offset endPoint = Offset(size.width * 1.0, size.height * 0.4);

    // canvas.drawLine(startPoint, endPoint, paint);

    // Exemplo de um traço mais "centralizado" e atravessado de forma mais proeminente:
    // Se você quiser um traço que vai de canto a canto, use:
    // final Offset startPoint = Offset(0, 0); // Canto superior esquerdo
    // final Offset endPoint = Offset(size.width, size.height); // Canto inferior direito
    // canvas.drawLine(startPoint, endPoint, paint);

    // Ou um traço do canto superior direito para o canto inferior esquerdo:
    // final Offset startPoint2 = Offset(size.width, 0); // Canto superior direito
    // final Offset endPoint2 = Offset(0, size.height); // Canto inferior esquerdo
    // canvas.drawLine(startPoint2, endPoint2, paint);
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Para um traço estático, este método deve retornar 'false'.
    // Isso informa ao Flutter que o desenho não precisa ser refeito a menos que
    // as propriedades do pintor (que não existem aqui) mudem.
    return false;
  }
}

