import 'package:flutter/material.dart';
import 'package:reflix/database/filme_dao.dart';

import '../model/filme_model.dart';
import 'star_rating.dart';


class FormularioScreen extends StatefulWidget {
  final Filme? filmeExistente;

  const FormularioScreen({super.key, this.filmeExistente});

  bool get _modoEdicao => filmeExistente != null;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final FilmeDao _dao = FilmeDao();

  late final TextEditingController _tituloController;
  late final TextEditingController _anoController;
  late final TextEditingController _comentarioController;

  TipoTitulo _tipo = TipoTitulo.filme;
  String _genero = ' ';
  double _nota = 0;
  bool _favorito = false;
  bool _salvando = false;

  static const List<String> _generosDisponiveis = [
    'Ficção científica',
    'Drama',
    'Ação',
    'Comédia',
    'Terror',
    'Animação',
    'Documentário',
    'Romance',
    'Fantasia',
    'Suspense',
    'Aventura',
    'Musical',
    'Histórico',
    'Guerra',
    'Crime',
    'Família',
    'Esporte',
    'Infantil',
    'Reality show',
  ];

  @override
  void initState() {
    super.initState();
    final existente = widget.filmeExistente;

    _tituloController = TextEditingController(text: existente?.titulo ?? '');
    _anoController = TextEditingController(
      text: existente != null ? existente.anoLancamento.toString() : '',
    );
    _comentarioController = TextEditingController(text: existente?.comentario ?? '');

    if (existente != null) {
      _tipo = existente.tipo;
      _genero = existente.genero;
      _nota = existente.nota;
      _favorito = existente.favorito;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _anoController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação adicional que não cabe no TextFormField: nota mínima.
    if (_nota == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê uma nota de pelo menos meia estrela.')),
      );
      return;
    }

    setState(() => _salvando = true);

    final filme = Filme(
      id: widget.filmeExistente?.id,
      titulo: _tituloController.text.trim(),
      tipo: _tipo,
      genero: _genero,
      anoLancamento: int.parse(_anoController.text.trim()),
      nota: _nota,
      comentario: _comentarioController.text.trim(),
      favorito: _favorito,
    );

    if (widget._modoEdicao) {
      await _dao.atualizar(filme);
    } else {
      await _dao.add(filme);
    }

    if (mounted) {
      // Retorna o filme  para quem chamou a tela 
      Navigator.pop(context, filme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._modoEdicao ? 'Editar título' : 'Novo título'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Widget tipo 1: campo de texto
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Filme / Série
            Text('Tipo', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            SegmentedButton<TipoTitulo>(
              segments: const [
                ButtonSegment(
                  value: TipoTitulo.filme,
                  label: Text('Filme'),
                  icon: Icon(Icons.movie_outlined),
                ),
                ButtonSegment(
                  value: TipoTitulo.serie,
                  label: Text('Série'),
                  icon: Icon(Icons.live_tv_outlined),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (novoValor) {
                setState(() => _tipo = novoValor.first);
              },
               style: SegmentedButton.styleFrom(
              selectedBackgroundColor: const Color.fromARGB(255, 206, 17, 4),
              selectedForegroundColor: Colors.white,
  ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Widget tipo 3: dropdown
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: null,
                    decoration: const InputDecoration(labelText: 'Gênero'),
                    items: _generosDisponiveis
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) setState(() => _genero = valor);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de texto numérico
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _anoController,
                    decoration: const InputDecoration(labelText: 'Ano'),
                    keyboardType: TextInputType.number,
                    validator: (valor) {
                      final ano = int.tryParse(valor ?? '');
                      final anoAtual = DateTime.now().year;
                      if (ano == null || ano < 1888 || ano > anoAtual) {
                        return 'Ano inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //avaliação por estrelas (substitui o slider)
            Text('Nota', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                StarRating(
                  nota: _nota,
                  editavel: true,
                  onChanged: (novaNota) => setState(() => _nota = novaNota),
                ),
                const SizedBox(width: 10),
                Text(
                  _nota == 0 ?  _nota.toStringAsFixed(1) : _nota.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Text(
              'Toque para nota cheia · toque e segure para meia estrela',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 20),       

            TextFormField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText:'O que achou?',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 240,
            ),

            // switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marcar como favorito'),
              value: _favorito,
              onChanged: (valor) => setState(() => _favorito = valor),
            ),
            const SizedBox(height: 8),

            FilledButton(
              onPressed: _salvando ? null : _salvar,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
