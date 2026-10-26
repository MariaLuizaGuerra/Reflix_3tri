import 'dart:io';
import 'package:app_filmes/model/filme_model.dart';
import 'package:flutter/material.dart';

/// Mostra a capa (arquivo ou link). Sem capa, mostra um ícone.
class CapaImagem extends StatelessWidget {
  final String? caminho;
  final TipoTitulo tipo;
  final BoxFit fit;
  final Color? fundo;
  final Color? corIcone;
  final double tamanhoIcone;

  const CapaImagem({
    super.key,
    required this.caminho,
    required this.tipo,
    this.fit = BoxFit.cover,
    this.fundo,
    this.corIcone,
    this.tamanhoIcone = 24,
  });

  static bool ehUrl(String? valor) =>
      valor != null && (valor.startsWith('http://') || valor.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = caminho;

    final placeholder = ColoredBox(
      color: fundo ?? theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          tipo == TipoTitulo.filme ? Icons.movie_outlined : Icons.live_tv_outlined,
          size: tamanhoIcone,
          color: corIcone ?? theme.colorScheme.outline,
        ),
      ),
    );

    if (c == null || c.isEmpty) return placeholder;


    if (ehUrl(c)) {
      return Image.network(
        c,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progresso) =>
            progresso == null ? child : placeholder,
      );
    }
    final arquivo = File(c);
    if (!arquivo.existsSync()) return placeholder;
    return Image.file(
      arquivo,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
