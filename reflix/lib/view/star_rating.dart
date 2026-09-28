import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double nota; // 0.0 a 5.0
  final bool editavel;
  final ValueChanged<double>? onChanged;
  final double tamanho;

  const StarRating({
    super.key,
    required this.nota,
    this.editavel = false,
    this.onChanged,
    this.tamanho = 28,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final posicao = index + 1;
        IconData icone;
        if (nota >= posicao) {
          icone = Icons.star; // cheia
        } else if (nota >= posicao - 0.5) {
          icone = Icons.star_half; // meia estrela
        } else {
          icone = Icons.star_border; // vazia
        }

        final estrela = Icon(icone, color: cor, size: tamanho);

        if (!editavel) return estrela;

        return GestureDetector(
          onTap: () => onChanged?.call(posicao.toDouble()),
          onLongPress: () => onChanged?.call(posicao - 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: estrela,
          ),
        );
      }),
    );
  }
}
