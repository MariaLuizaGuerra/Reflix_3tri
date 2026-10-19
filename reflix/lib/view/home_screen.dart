import 'package:flutter/material.dart';
import 'usuario_model.dart';
import 'filme_model.dart';
import 'filme_dao.dart';
import 'filme_card.dart';
import 'detalhes_screen.dart';
import 'formulario_screen.dart';
import 'login_screen.dart';

/// Tela principal. Mostra o catálogo do usuário logado em duas abas:
/// "Assistidos" e "Para assistir" (lista de desejos).
class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FilmeDao _dao = FilmeDao();

  StatusTitulo _aba = StatusTitulo.assistido;
  List<Filme> _filmes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final lista = await _dao.listarPorUsuario(widget.usuario.id!, _aba);
    if (!mounted) return;
    setState(() {
      _filmes = lista;
      _carregando = false;
    });
  }

  void _trocarAba(StatusTitulo nova) {
    if (nova == _aba) return;
    _aba = nova;
    _carregar();
  }

  Future<void> _alternarFavorito(Filme filme) async {
    await _dao.alternarFavorito(filme.id!, !filme.favorito);
    await _carregar();
  }

  Future<void> _confirmarExclusao(Filme filme) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir título'),
        content: Text('Deseja realmente excluir "${filme.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await _dao.remover(filme.id!);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${filme.titulo}" removido.')),
    );
  }

  Future<void> _abrirDetalhes(Filme filme) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(filme: filme)),
    );
    if (resultado != null) await _carregar();
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormularioScreen(usuarioId: widget.usuario.id!)),
    );
    if (resultado != null) await _carregar();
  }

  void _abrirDashboard() {
    // TODO: Navigator.push para a DashboardScreen quando for implementada.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard em breve.')),
    );
  }

  void _sair() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REFLIX'),
        actions: [
          IconButton(
            tooltip: 'Meu Dashboard',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: _abrirDashboard,
          ),
          PopupMenuButton<String>(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (valor) {
              if (valor == 'sair') _sair();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(widget.usuario.nome),
              ),
              const PopupMenuItem(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _Abas(selecionada: _aba, onSelecionada: _trocarAba),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _filmes.isEmpty
                    ? _ListaVazia(aba: _aba)
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 88),
                          itemCount: _filmes.length,
                          itemBuilder: (context, i) {
                            final filme = _filmes[i];
                            return FilmeCard(
                              filme: filme,
                              onTap: () => _abrirDetalhes(filme),
                              onFavoritar: () => _alternarFavorito(filme),
                              onExcluir: () => _confirmarExclusao(filme),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Adicionar título',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Abas "Assistidos" / "Para assistir" em formato de chips.
class _Abas extends StatelessWidget {
  final StatusTitulo selecionada;
  final ValueChanged<StatusTitulo> onSelecionada;
  const _Abas({required this.selecionada, required this.onSelecionada});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final status in StatusTitulo.values) ...[
            ChoiceChip(
              label: Text(status == StatusTitulo.assistido ? 'Assistidos' : 'Para assistir'),
              selected: selecionada == status,
              onSelected: (_) => onSelecionada(status),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  final StatusTitulo aba;
  const _ListaVazia({required this.aba});

  @override
  Widget build(BuildContext context) {
    final assistidos = aba == StatusTitulo.assistido;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            assistidos ? Icons.movie_filter_outlined : Icons.bookmark_border,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(assistidos
              ? 'Você ainda não registrou nenhum título.'
              : 'Sua lista de desejos está vazia.'),
          const SizedBox(height: 4),
          const Text('Toque no + para adicionar.'),
        ],
      ),
    );
  }
}
