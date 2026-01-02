import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  final dynamic review; // Usando dynamic para evitar erros se você ainda não tiver um Model de Review

  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Usuário Anônimo", // Se tiver nome no model, use review.userName
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: List.generate(5, (index) {
                  return const Icon(Icons.star, color: Colors.amber, size: 16);
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.toString(), // Aqui vai o texto da avaliação
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}