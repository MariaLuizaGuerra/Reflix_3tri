import 'dart:io';

import 'package:app_filmes/database/filme_dao.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../model/filme_model.dart';
import 'capa_imagem.dart';
import 'star_rating.dart';

/// Tela 3 - Cadastro e edição de título.
class FormularioScreen extends StatefulWidget {
  final int usuarioId;
  final Filme? filmeExistente;

  const FormularioScreen({
    super.key,
    required this.usuarioId,
    this.filmeExistente,
  });

  bool get _modoEdicao => filmeExistente != null;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final FilmeDao _dao = FilmeDao();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _tituloController;
  late final TextEditingController _anoController;
  late final TextEditingController _comentarioController;

  TipoTitulo _tipo = TipoTitulo.filme;
  String? _genero;
  StatusTitulo _status = StatusTitulo.assistido;
  double _nota = 0;
  DateTime _dataAssistido = DateTime.now();
  String? _caminhoFoto; // arquivo local ou URL
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

  bool get _assistido => _status == StatusTitulo.assistido;

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
      _genero = _generosDisponiveis.contains(existente.genero) ? existente.genero : null;
      _status = existente.status;
      _nota = existente.nota;
      _dataAssistido = existente.dataAssistido ?? DateTime.now();
      _caminhoFoto = existente.caminhoFoto;
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

  // ---------------- Foto ----------------

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Copia a imagem para a pasta do app (o cache pode ser apagado)
  Future<String> _copiarParaPastaDoApp(XFile arquivo) async {
    final base = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(base.path, 'capas'));
    if (!await pasta.exists()) await pasta.create(recursive: true);
    final destino = p.join(
      pasta.path,
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(arquivo.path)}',
    );
    await File(arquivo.path).copy(destino);
    return destino;
  }

  Future<void> _escolherFoto(ImageSource origem) async {
    try {
      final arquivo = await _picker.pickImage(
        source: origem,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (arquivo == null) return; // usuário cancelou
      final caminho = await _copiarParaPastaDoApp(arquivo);
      if (!mounted) return;
      setState(() => _caminhoFoto = caminho);
    } catch (_) {
      _mostrarMensagem(origem == ImageSource.camera
          ? 'Não foi possível abrir a câmera neste dispositivo.'
          : 'Não foi possível abrir a galeria.');
    }
  }

  Future<void> _informarUrl() async {
    final controller = TextEditingController(
      text: CapaImagem.ehUrl(_caminhoFoto) ? _caminhoFoto : '',
    );
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imagem da internet'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    final valida = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    if (!valida) {
      _mostrarMensagem('Informe um link que comece com http:// ou https://');
      return;
    }
    setState(() => _caminhoFoto = url);
  }

  // ---------------- Data ----------------

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataAssistido.isAfter(hoje) ? hoje : _dataAssistido,
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Quando você assistiu?',
    );
    if (escolhida != null) setState(() => _dataAssistido = escolhida);
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ---------------- Salvar ----------------

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_assistido && _nota == 0) {
      _mostrarMensagem('Dê uma nota de pelo menos meia estrela.');
      return;
    }

    setState(() => _salvando = true);

    // "Para assistir" não guarda nota, data nem comentário
    final filme = Filme(
      id: widget.filmeExistente?.id,
      usuarioId: widget.usuarioId,
      titulo: _tituloController.text.trim(),
      tipo: _tipo,
      genero: _genero!,
      anoLancamento: int.parse(_anoController.text.trim()),
      status: _status,
      nota: _assistido ? _nota : 0,
      dataAssistido: _assistido ? _dataAssistido : null,
      comentario: _assistido ? _comentarioController.text.trim() : '',
      caminhoFoto: _caminhoFoto,
      favorito: _assistido ? _favorito : false,
    );

    if (widget._modoEdicao) {
      await _dao.atualizar(filme);
    } else {
      await _dao.add(filme);
    }

    if (mounted) Navigator.pop(context, filme);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._modoEdicao ? 'Editar título' : 'Novo título'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFoto(theme),
            const SizedBox(height: 20),

            const _Rotulo('Título'),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(hintText: 'Ex: Duna'),
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return 'Informe o título';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo, gênero e ano na mesma linha
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<TipoTitulo>(
                    initialValue: _tipo,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: TipoTitulo.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) setState(() => _tipo = valor);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    initialValue: _genero,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    hint: const Text('Gênero', overflow: TextOverflow.ellipsis),
                    items: _generosDisponiveis
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) setState(() => _genero = valor);
                    },
                    validator: (valor) => valor == null ? 'Escolha' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _anoController,
                    decoration: const InputDecoration(hintText: 'Ano'),
                    keyboardType: TextInputType.number,
                    validator: (valor) {
                      final ano = int.tryParse(valor ?? '');
                      final anoAtual = DateTime.now().year;
                      if (ano == null || ano < 1888 || ano > anoAtual) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _Rotulo('Status'),
            Row(
              children: [
                Expanded(
                  child: _BotaoStatus(
                    texto: StatusTitulo.assistido.label,
                    selecionado: _assistido,
                    onTap: () => setState(() => _status = StatusTitulo.assistido),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BotaoStatus(
                    texto: StatusTitulo.paraAssistir.label,
                    selecionado: !_assistido,
                    onTap: () => setState(() => _status = StatusTitulo.paraAssistir),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildPainelAvaliacao(theme),
            const SizedBox(height: 20),

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

  // Botões de foto, ou a prévia da capa escolhida
  Widget _buildFoto(ThemeData theme) {
    if (_caminhoFoto != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: CapaImagem(
                caminho: _caminhoFoto,
                tipo: _tipo,
                fundo: Colors.black,
                corIcone: theme.colorScheme.primary,
                tamanhoIcone: 48,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              tooltip: 'Remover capa',
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => setState(() => _caminhoFoto = null),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _BotaoFoto(
            icone: Icons.photo_camera_outlined,
            texto: 'Câmera',
            onTap: () => _escolherFoto(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BotaoFoto(
            icone: Icons.image_outlined,
            texto: 'Galeria',
            onTap: () => _escolherFoto(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BotaoFoto(
            icone: Icons.public,
            texto: 'Internet',
            onTap: _informarUrl,
          ),
        ),
      ],
    );
  }

  // Nota, data e comentário (só para "Já assistido")
  Widget _buildPainelAvaliacao(ThemeData theme) {
    return Opacity(
      opacity: _assistido ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !_assistido,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2B2B2B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liberados para "Já assistido"',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StarRating(
                    nota: _nota,
                    editavel: true,
                    onChanged: (novaNota) => setState(() => _nota = novaNota),
                  ),
                  const SizedBox(width: 10),
                  Text(_nota.toStringAsFixed(1), style: theme.textTheme.bodyLarge),
                ],
              ),
              Text(
                'Toque para nota cheia · toque e segure para meia estrela',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _escolherData,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  child: Text(_formatarData(_dataAssistido)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(hintText: 'Comentário...'),
                maxLines: 3,
                maxLength: 240,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rótulo pequeno acima dos campos.
class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}

/// Botão quadrado de foto (Câmera / Galeria / Internet).
class _BotaoFoto extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  const _BotaoFoto({required this.icone, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(texto, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Botão de status.
class _BotaoStatus extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;
  const _BotaoStatus({required this.texto, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado ? theme.colorScheme.primary : const Color(0xFF181818),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionado ? theme.colorScheme.primary : const Color(0xFF2B2B2B),
          ),
        ),
        child: Text(
          texto,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
