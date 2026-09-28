import 'package:flutter/material.dart';
import 'package:reflix/database/filme_dao.dart';

import '../model/filme_model.dart';
import 'formulario_screen.dart';
import 'star_rating.dart';

class DetalhesScreen extends StatefulWidget {
  final Filme filme;

  const DetalhesScreen({super.key, required this.filme});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final FilmeDao _dao = FilmeDao();
  late Filme _filme; 
  
  @override
  void initState() {
    super.initState();
    _filme = widget.filme;
  }

  Future<void> _alternarFavorito() async {
    await _dao.alternarFavorito(_filme.id!, !_filme.favorito);
    setState(() {
      _filme = _filme.copyWith(favorito: !_filme.favorito);
    });
  }

  Future<void> _abrirEdicao() async {
    final atualizado = await Navigator.push<Filme>(
      context,
      MaterialPageRoute(builder: (_) => FormularioScreen(filmeExistente: _filme)),
    );
    // Se a tela de edição retornou um filme atualizado, refletimos aqui.
    if (atualizado != null) {
      setState(() => _filme = atualizado);
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir título'),
        content: Text('Deseja realmente excluir "${_filme.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _dao.remover(_filme.id!);
      if (mounted) {
        // Sinaliza para a Home (via pop com valor) que o item foi removido.
        Navigator.pop(context, 'excluido');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_filme.titulo, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // foto
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Icon(
                _filme.tipo == TipoTitulo.filme
                    ? Icons.movie_outlined
                    : Icons.live_tv_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            _Badge(texto: _filme.tipo.label.toUpperCase()),
            const SizedBox(height: 16),

            // Estrelas em modo somente leitura
            StarRating(nota: _filme.nota, tamanho: 26),
            const SizedBox(height: 16),

            _InfoLinha(icone: Icons.category_outlined, texto: _filme.genero),
            _InfoLinha(
              icone: Icons.calendar_today_outlined,
              texto: 'Lançamento: ${_filme.anoLancamento}',
            ),
            
            if (_filme.comentario.trim().isNotEmpty)
              _InfoLinha(
                icone: Icons.chat_bubble_outline,
                texto: _filme.comentario,
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _alternarFavorito,
                    icon: Icon(
                      _filme.favorito ? Icons.favorite : Icons.favorite_border,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(_filme.favorito ? 'Favoritado' : 'Favoritar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _abrirEdicao,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _confirmarExclusao,
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                label: Text(
                  'Excluir',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "FILME" / "SÉRIE"
class _Badge extends StatelessWidget {
  final String texto;
  const _Badge({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}


class _InfoLinha extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _InfoLinha({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
