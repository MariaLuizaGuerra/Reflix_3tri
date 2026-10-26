import 'package:app_filmes/data/catalogo_recomendacoes.dart';
import 'package:app_filmes/database/filme_dao.dart';
import 'package:app_filmes/model/filme_model.dart';
import 'package:app_filmes/model/usuario_model.dart';
import 'package:flutter/material.dart';

/// Tela 5 - Dashboard com estatísticas e recomendações.
class DashboardScreen extends StatefulWidget {
  final Usuario usuario;
  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _MesBarra {
  final String rotulo;
  final int quantidade;
  final bool atual;
  const _MesBarra(this.rotulo, this.quantidade, this.atual);
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _mesesAbrev = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  static const int _mesesNoGrafico = 6;
  static const int _maxRecomendacoes = 2;

  final FilmeDao _dao = FilmeDao();

  bool _carregando = true;
  String? _erro;
  int _totalAssistidos = 0;
  String? _generoQueridinho;
  int _titulosDoGenero = 0;
  double? _mediaGeral;
  List<_MesBarra> _barras = [];
  List<Recomendacao> _recomendacoes = [];
  List<String> _generosBase = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final id = widget.usuario.id;
      if (id == null) {
        throw StateError('Usuário sem id (widget.usuario.id é null).');
      }

      final assistidos =
          await _dao.listarPorUsuario(id, StatusTitulo.assistido);
      final desejos =
          await _dao.listarPorUsuario(id, StatusTitulo.paraAssistir);
      if (!mounted) return;

      // Estatísticas calculadas direto no SQLite
      final total = await _dao.contarAssistidos(id);
      final favorito = await _dao.generoFavorito(id);
      final mediaGeral = await _dao.mediaGeral(id);
      final porMes = await _dao.assistidosPorMes(id);
      if (!mounted) return;

      String? melhorGenero;
      int titulosDoGenero = 0;
      if (favorito != null) {
        melhorGenero = favorito['genero'] as String?;
        // num cobre int e double vindos do SQLite
        titulosDoGenero = (favorito['total'] as num?)?.toInt() ?? 0;
      }

      // Barras: últimos 6 meses (o último é o mês atual)
      final agora = DateTime.now();
      final barras = <_MesBarra>[];
      for (var i = _mesesNoGrafico - 1; i >= 0; i--) {
        final mes = DateTime(agora.year, agora.month - i);
        final chave = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';
        final qtd = porMes[chave] ?? 0;
        barras.add(_MesBarra(_mesesAbrev[mes.month - 1], qtd, i == 0));
      }

      // Títulos que o usuário já tem (para não recomendar de novo)
      final jaCadastrados = <String>[];
      for (final f in assistidos) {
        jaCadastrados.add(f.titulo.trim().toLowerCase());
      }
      for (final f in desejos) {
        jaCadastrados.add(f.titulo.trim().toLowerCase());
      }

      // Recomendações: pega do catálogo do gênero queridinho
      final recomendacoes = <Recomendacao>[];
      final generosUsados = <String>[];
      if (melhorGenero != null) {
        final lista = catalogoRecomendacoes[melhorGenero] ?? [];
        for (final r in lista) {
          if (recomendacoes.length >= _maxRecomendacoes) break;
          if (jaCadastrados.contains(r.titulo.trim().toLowerCase())) continue;
          recomendacoes.add(r);
        }
        if (recomendacoes.isNotEmpty) generosUsados.add(melhorGenero);
      }

      if (!mounted) return;
      setState(() {
        _totalAssistidos = total;
        _generoQueridinho = melhorGenero;
        _titulosDoGenero = titulosDoGenero;
        _mediaGeral = mediaGeral;
        _barras = barras;
        _recomendacoes = recomendacoes;
        _generosBase = generosUsados;
        _erro = null;
        _carregando = false;
      });
    } catch (e, st) {
      // Mostra o erro real no console e destrava a tela
      debugPrint('ERRO no dashboard: $e\n$st');
      if (!mounted) return;
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  // O botão + salva a recomendação em "Para assistir"
  Future<void> _adicionar(Recomendacao r) async {
    try {
      await _dao.add(Filme(
        usuarioId: widget.usuario.id!,
        titulo: r.titulo,
        tipo: r.tipo,
        genero: r.genero,
        anoLancamento: r.ano,
        status: StatusTitulo.paraAssistir,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${r.titulo}" adicionado em Para assistir.')),
      );
      await _carregar();
    } catch (e, st) {
      debugPrint('ERRO ao adicionar recomendação: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível adicionar o título.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget corpo;
    if (_carregando) {
      corpo = const Center(child: CircularProgressIndicator());
    } else if (_erro != null) {
      corpo = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 40, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar o dashboard.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _erro = null;
                    _carregando = true;
                  });
                  _carregar();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    } else {
      corpo = RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CardEstatistica(
                    icone: Icons.workspace_premium_outlined,
                    rotulo: 'Gênero queridinho',
                    valor: _generoQueridinho ?? '—',
                    detalhe: _titulosDoGenero == 1
                        ? '1 título'
                        : '$_titulosDoGenero títulos',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardEstatistica(
                    icone: Icons.star_border_rounded,
                    rotulo: 'Média geral',
                    valor: _mediaGeral == null
                        ? '—'
                        : _mediaGeral!.toStringAsFixed(1),
                    detalhe: 'de 5 estrelas',
                  ),
                ),
              ],
            ),
            ),
            const SizedBox(height: 12),
            _GraficoMensal(barras: _barras, total: _totalAssistidos),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.bolt_outlined,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Recomendados pra você',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _recomendacoes.isEmpty
                  ? (_totalAssistidos == 0
                      ? 'Registre títulos assistidos para receber recomendações.'
                      : 'Você já cadastrou todas as sugestões dos seus gêneros favoritos.')
                  : 'com base em ${_generosBase.join(', ')} · ainda não cadastrados',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 10),
            for (final r in _recomendacoes)
              _ItemRecomendacao(
                  recomendacao: r, onAdicionar: () => _adicionar(r)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Dashboard')),
      body: corpo,
    );
  }
}

/// Cartão de estatística (gênero queridinho, média).
class _CardEstatistica extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final String detalhe;

  const _CardEstatistica({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suave =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        children: [
          Icon(icone, color: theme.colorScheme.primary, size: 26),
          const SizedBox(height: 6),
          Text(rotulo, style: suave, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            valor,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(detalhe, style: suave),
        ],
      ),
    );
  }
}

/// Gráfico de barras feito com Containers. Mês atual em cinza.
class _GraficoMensal extends StatelessWidget {
  final List<_MesBarra> barras;
  final int total;
  const _GraficoMensal({required this.barras, required this.total});

  static const double _alturaMaxima = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suave =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);
    // Maior quantidade entre as barras (define a altura máxima)
    int maior = 0;
    for (final b in barras) {
      if (b.quantidade > maior) maior = b.quantidade;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assistidos por mês', style: suave),
              Text(
                '$total no total',
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _alturaMaxima + 38,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in barras)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(b.quantidade == 0 ? '' : '${b.quantidade}',
                              style: suave),
                          const SizedBox(height: 4),
                          Container(
                            height: (b.quantidade == 0 || maior == 0)
                                ? 3
                                : _alturaMaxima * b.quantidade / maior,
                            decoration: BoxDecoration(
                              color: b.quantidade == 0
                                  ? const Color(0xFF2B2B2B)
                                  : (b.atual
                                      ? const Color(0xFF6B6B6B)
                                      : theme.colorScheme.primary),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(b.rotulo, style: suave),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Item da lista de recomendações.
class _ItemRecomendacao extends StatelessWidget {
  final Recomendacao recomendacao;
  final VoidCallback onAdicionar;
  const _ItemRecomendacao(
      {required this.recomendacao, required this.onAdicionar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              recomendacao.tipo == TipoTitulo.filme
                  ? Icons.movie_outlined
                  : Icons.live_tv_outlined,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recomendacao.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${recomendacao.ano} · ${recomendacao.tipo.label}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Adicionar em Para assistir',
            onPressed: onAdicionar,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
