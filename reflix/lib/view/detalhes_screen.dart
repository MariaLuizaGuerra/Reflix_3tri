import 'package:app_filmes/database/filme_dao.dart';
import 'package:app_filmes/database/lembrete_dao.dart';
import 'package:app_filmes/model/lembrete_model.dart';
import 'package:flutter/material.dart';
import '../model/filme_model.dart';
import 'star_rating.dart';
import 'formulario_screen.dart';
import 'capa_imagem.dart';

/// Tela 2 - Detalhes (READ individual + flag UPDATE + DELETE).
/// StatefulWidget porque o botão de favorito precisa refletir a mudança
/// imediatamente na própria tela, sem esperar voltar para a Home.
class DetalhesScreen extends StatefulWidget {
  final Filme filme;

  const DetalhesScreen({super.key, required this.filme});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final FilmeDao _dao = FilmeDao();
  final LembreteDao _lembreteDao = LembreteDao();
  late Filme _filme; // cópia local para refletir alterações sem novo fetch
  Lembrete? _lembrete;

  @override
  void initState() {
    super.initState();
    _filme = widget.filme;
    _carregarLembrete();
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _carregarLembrete() async {
    final lembrete = await _lembreteDao.buscarPorFilme(_filme.id!);
    if (!mounted) return;
    setState(() => _lembrete = lembrete);
  }

  Future<void> _definirLembrete() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _lembrete?.dataLembrete ?? hoje,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 2),
      helpText: 'Quando você quer assistir?',
    );
    if (escolhida == null) return;

    final lembrete = Lembrete(
      id: _lembrete?.id,
      usuarioId: _filme.usuarioId,
      filmeId: _filme.id!,
      dataLembrete: escolhida,
      mensagem: 'Assistir "${_filme.titulo}"',
    );

    if (_lembrete == null) {
      await _lembreteDao.add(lembrete);
    } else {
      await _lembreteDao.atualizar(lembrete);
    }
    await _carregarLembrete();
  }

  Future<void> _removerLembrete() async {
    await _lembreteDao.removerPorFilme(_filme.id!);
    await _carregarLembrete();
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
      MaterialPageRoute(builder: (_) => FormularioScreen(usuarioId: _filme.usuarioId, filmeExistente: _filme)),
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
    final assistido = _filme.status == StatusTitulo.assistido;
    final data = _filme.dataAssistido;
    final dataFormatada = data == null
        ? '-'
        : '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_filme.titulo, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa ou ícone
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 190,
                child: CapaImagem(
                  caminho: _filme.caminhoFoto,
                  tipo: _filme.tipo,
                  fundo: Colors.black,
                  corIcone: theme.colorScheme.primary,
                  tamanhoIcone: 56,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _Badge(texto: _filme.tipo.label.toUpperCase()),
                const SizedBox(width: 8),
                _Badge(
                  texto: _filme.status.label.toUpperCase(),
                  destaque: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estrelas (só para quem já assistiu)
            if (assistido) ...[
              StarRating(nota: _filme.nota, tamanho: 26),
              const SizedBox(height: 16),
            ],

            _InfoLinha(icone: Icons.sell_outlined, texto: _filme.genero),
            _InfoLinha(
              icone: Icons.calendar_today_outlined,
              texto: 'Lançamento: ${_filme.anoLancamento}',
            ),
            if (assistido)
              _InfoLinha(
                icone: Icons.check,
                texto: 'Assistido em $dataFormatada',
              ),
            if (assistido && _filme.comentario.trim().isNotEmpty)
              _InfoLinha(
                icone: Icons.chat_bubble_outline,
                texto: _filme.comentario,
              ),

            if (!assistido) ...[
              _InfoLinha(
                icone: Icons.notifications_none,
                texto: _lembrete == null
                    ? 'Sem lembrete'
                    : '${_lembrete!.mensagem} em ${_formatarData(_lembrete!.dataLembrete)}',
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _definirLembrete,
                    icon: const Icon(Icons.alarm_add_outlined),
                    label: Text(_lembrete == null ? 'Criar lembrete' : 'Alterar lembrete'),
                  ),
                  if (_lembrete != null)
                    TextButton(
                      onPressed: _removerLembrete,
                      child: const Text('Remover'),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                if (assistido) ...[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _alternarFavorito,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2B2B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: Icon(
                        _filme.favorito ? Icons.favorite : Icons.favorite_border,
                        color: theme.colorScheme.primary,
                      ),
                      label: const Text('Favorito'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _abrirEdicao,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmarExclusao,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: theme.colorScheme.onSurface,
                  side: const BorderSide(color: Color(0xFF2B2B2B)),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selo "FILME" / "SÉRIE", reaproveitando o mesmo estilo do card da lista.
class _Badge extends StatelessWidget {
  final String texto;
  final bool destaque; // fundo vermelho
  const _Badge({required this.texto, this.destaque = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: destaque ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: destaque ? Colors.white : null,
        ),
      ),
    );
  }
}

/// Linha de informação com ícone + texto, reutilizada várias vezes na tela.
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
