import 'package:flutter/material.dart';

import '../model/filme_model.dart';

/// Card individual da lista. StatelessWidget: não guarda estado próprio,
/// apenas exibe dados e dispara callbacks para o widget pai (HomeScreen).
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

  
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone de destaque (poderia virar um pôster futuramente)
              Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      filme.tipo == TipoTitulo.filme
                          ? Icons.movie_outlined
                          : Icons.live_tv_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Excluir',
                    color: theme.colorScheme.outline,
                    onPressed: onExcluir,
                  ),
                  IconButton(
                    icon: Icon(
                      filme.favorito ? Icons.favorite : Icons.favorite_border,
                      color: filme.favorito ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                    tooltip: 'Marcar como favorito',
                    onPressed: onFavoritar,
                  ),

                ],
              ),
              const SizedBox(width: 12),
              // Título + metadados
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filme.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                        
                        Text(
                          '${filme.nota.toStringAsFixed(1)} · ${filme.anoLancamento}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        _BadgeTipo(tipo: filme.tipo),
                      ],
                    ),
                  ],
                ),
                
              ),
              // Favoritar (UPDATE rápido do flag)
              //IconButton(
              //icon: Icon(
              //filme.favorito ? Icons.favorite : Icons.favorite_border,
              // color: filme.favorito ? theme.colorScheme.primary : theme.colorScheme.outline,
              // ),
              // tooltip: 'Marcar como favorito',
              //onPressed: onFavoritar,
              //),

              // IconButton(
              //   icon: const Icon(Icons.delete_outline),
              //   tooltip: 'Excluir',
              //   color: theme.colorScheme.outline,
              //   onPressed: onExcluir,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pequeno selo "FILME" / "SÉRIE" 
class _BadgeTipo extends StatelessWidget {
  final TipoTitulo tipo;
  const _BadgeTipo({required this.tipo});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destaque = tipo == TipoTitulo.serie;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: destaque
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      
      child: Text(
        tipo.label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: destaque ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      
    );

  }
  
}
