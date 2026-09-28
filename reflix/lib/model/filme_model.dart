enum TipoTitulo {
  filme,
  serie;

  String get valorBanco => name;

  String get label => this == TipoTitulo.filme ? 'Filme' : 'Série';

  static TipoTitulo fromBanco(String valor) {
    return TipoTitulo.values.firstWhere(
      (t) => t.valorBanco == valor,
      orElse: () => TipoTitulo.filme,
    );
  }
}

/// Entidade principal do aplicativo.
class Filme {
  final int? id; 
  final String titulo;
  final TipoTitulo tipo;
  final String genero;
  final int anoLancamento;
  final double nota; 
  final String comentario;
  final bool favorito; 

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

  /// Converção de Dart para Map para salvar
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo.valorBanco,
      'genero': genero,
      'anoLancamento': anoLancamento,
      'nota': nota,
      'comentario': comentario,
      'favorito': favorito ? 1 : 0, 
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
