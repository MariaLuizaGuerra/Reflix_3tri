/// Enum que representa se o título é um Filme ou uma Série.
/// Usar enum em vez de String solta evita valores inválidos no banco.
enum TipoTitulo {
  filme,
  serie;

  /// Converte o enum para o valor salvo no SQLite (String).
  String get valorBanco => name;

  /// Texto amigável para exibir na UI.
  String get label => this == TipoTitulo.filme ? 'Filme' : 'Série';

  /// Reconstrói o enum a partir do valor salvo no banco.
  static TipoTitulo fromBanco(String valor) {
    return TipoTitulo.values.firstWhere(
      (t) => t.valorBanco == valor,
      orElse: () => TipoTitulo.filme,
    );
  }
}

/// Entidade principal do aplicativo.
/// Representa um filme ou série avaliado pelo usuário.
class Filme {
  final int? id; // chave primária (autoincrement no SQLite)
  final String titulo;
  final TipoTitulo tipo;
  final String genero;
  final int anoLancamento;
  final double nota; // 0.0 a 5.0
  final String comentario;
  final bool favorito; // flag alterável rapidamente na lista

  const Filme({
    this.id,
    required this.titulo,
    required this.tipo,
    required this.genero,
    required this.anoLancamento,
    required this.nota,
    this.comentario = '',
    this.favorito = false,
  });

  /// Cria uma cópia do objeto alterando apenas os campos informados.
  /// Muito útil para o UPDATE do flag "favorito" sem tocar no resto.
  Filme copyWith({
    int? id,
    String? titulo,
    TipoTitulo? tipo,
    String? genero,
    int? anoLancamento,
    double? nota,
    String? comentario,
    bool? favorito,
  }) {
    return Filme(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      genero: genero ?? this.genero,
      anoLancamento: anoLancamento ?? this.anoLancamento,
      nota: nota ?? this.nota,
      comentario: comentario ?? this.comentario,
      favorito: favorito ?? this.favorito,
    );
  }

  /// Converte o objeto Dart em Map para salvar no SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo.valorBanco,
      'genero': genero,
      'anoLancamento': anoLancamento,
      'nota': nota,
      'comentario': comentario,
      'favorito': favorito ? 1 : 0, // SQLite não tem tipo bool nativo
    };
  }

  /// Reconstrói o objeto Dart a partir de uma linha do SQLite.
  factory Filme.fromMap(Map<String, Object?> map) {
    return Filme(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      tipo: TipoTitulo.fromBanco(map['tipo'] as String),
      genero: map['genero'] as String,
      anoLancamento: map['anoLancamento'] as int,
      nota: (map['nota'] as num).toDouble(),
      comentario: map['comentario'] as String? ?? '',
      favorito: (map['favorito'] as int) == 1,
    );
  }
}
