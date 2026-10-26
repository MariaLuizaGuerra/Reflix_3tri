import 'package:app_filmes/model/filme_model.dart';
import 'package:flutter/material.dart';
import 'capa_imagem.dart';
import 'star_rating.dart';

/// Card de um título na lista: capa, título, estrelas, favorito e excluir.
class FilmeCard extends StatelessWidget {
  final Filme filme;
  final VoidCallback onTap;
  final VoidCallback onFavoritar;
  final VoidCallback onExcluir;

  const FilmeCard({
    super.key,
    required this.filme,
    required this.onTap,
    required this.onFavoritar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assistido = filme.status == StatusTitulo.assistido;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 52,
                  height: 72,
                  child: CapaImagem(caminho: filme.caminhoFoto, tipo: filme.tipo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filme.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    // Estrelas só existem para quem já assistiu.
                    if (assistido) StarRating(nota: filme.nota, tamanho: 16),
                    const SizedBox(height: 4),
                    Text(
                      '${filme.anoLancamento} · ${filme.genero} · ${filme.tipo.label}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (assistido)
                IconButton(
                  tooltip: 'Favoritar',
                  onPressed: onFavoritar,
                  icon: Icon(
                    filme.favorito ? Icons.favorite : Icons.favorite_border,
                    color: filme.favorito ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: onExcluir,
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
