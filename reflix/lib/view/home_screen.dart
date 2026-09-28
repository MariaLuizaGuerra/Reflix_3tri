import 'package:flutter/material.dart';
import 'package:reflix/database/filme_dao.dart';

import '../model/filme_model.dart';
import 'detalhes_screen.dart';
import 'filme_card.dart';
import 'formulario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FilmeDao _dao = FilmeDao();

  List<Filme> _todosFilmes = [];
  List<Filme> _filmesExibidos = [];
  TipoTitulo? _filtroTipo; 
  bool _carregando = true;

  @override
  //busca  filmes no banco
  void initState() {
    super.initState();
    _carregarFilmes();
  }

  Future<void> _carregarFilmes() async {
    setState(() => _carregando = true);
    final lista = await _dao.listarTodos();
    setState(() {
      _todosFilmes = lista;
      _aplicarFiltro();
      _carregando = false;
    });
  }

  void _aplicarFiltro() {
    _filmesExibidos = _filtroTipo == null
        ? _todosFilmes
        : _todosFilmes.where((f) => f.tipo == _filtroTipo).toList();
  }

  Future<void> _alternarFavorito(Filme filme) async {
    await _dao.alternarFavorito(filme.id!, !filme.favorito);
    await _carregarFilmes();
  }

  Future<void> _confirmarExclusao(Filme filme) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir título'),
        content: Text('Deseja realmente excluir "${filme.titulo}"?'),
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

    if (confirmou == true && filme.id != null) {
      await _dao.remover(filme.id!);
      await _carregarFilmes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${filme.titulo}" removido.')),
        );
      }
    }
  }

  // Abre a Tela 2 (Detalhes)
  Future<void> _abrirDetalhes(Filme filme) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(filme: filme)),
    );
    if (resultado == 'excluido' || resultado is Filme) {
      await _carregarFilmes();
    }
  }

  // Abre a Tela 3 (Cadastro) em modo CREATE (sem filmeExistente).
  Future<void> _abrirCadastro() async {
    final novo = await Navigator.push<Filme>(
      context,
      MaterialPageRoute(builder: (_) => const FormularioScreen()),
    );
    if (novo != null) {
      await _carregarFilmes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEUS Filmes'),
      ),
      body: Column(
        children: [
          _FiltroTipo(
            selecionado: _filtroTipo,
            onSelecionado: (tipo) {
              setState(() {
                _filtroTipo = tipo;
                _aplicarFiltro();
              });
            },
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _filmesExibidos.isEmpty
                    ? const _ListaVazia()
                    : RefreshIndicator(
                        onRefresh: _carregarFilmes,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filmesExibidos.length,
                          itemBuilder: (context, index) {
                            final filme = _filmesExibidos[index];
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
      //+
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Adicionar título',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Filtro (Todos / Filme / Série)
class _FiltroTipo extends StatelessWidget {
  final TipoTitulo? selecionado;
  final ValueChanged<TipoTitulo?> onSelecionado;

  const _FiltroTipo({required this.selecionado, required this.onSelecionado});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _chip(context, label: 'Todos', valor: null),
          const SizedBox(width: 8),
          _chip(context, label: 'Filmes', valor: TipoTitulo.filme),
          const SizedBox(width: 8),
          _chip(context, label: 'Séries', valor: TipoTitulo.serie),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {required String label, required TipoTitulo? valor}) {
    final ativo = selecionado == valor;
    return ChoiceChip(
      label: Text(label),
      selected: ativo,
      onSelected: (_) => onSelecionado(valor),
    );
  }
}

/// Mensagem exibida quando não há nenhum título cadastrado 
class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum título por aqui ainda.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          const Text('Toque no + para adicionar.'),
        ],
      ),
    );
  }
}
