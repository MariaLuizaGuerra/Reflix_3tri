/// Enum que representa se o título é um Filme ou uma Série.
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

/// Enum que representa se o título já foi assistido ou está na lista de desejos.
enum StatusTitulo {
  assistido,
  paraAssistir;

  String get valorBanco => name;
  String get label => this == StatusTitulo.assistido ? 'Já assistido' : 'Para assistir';

  static StatusTitulo fromBanco(String valor) {
    return StatusTitulo.values.firstWhere(
      (s) => s.valorBanco == valor,
      orElse: () => StatusTitulo.assistido,
    );
  }
}

/// Entidade principal do aplicativo.
class Filme {
  final int? id;
  final int usuarioId; // Adicionado
  final String titulo;
  final TipoTitulo tipo;
  final String genero;
  final int anoLancamento;
  final StatusTitulo status; // Adicionado
  final double nota; // 0.0 a 5.0
  final DateTime? dataAssistido; // Adicionado
  final String comentario;
  final String? caminhoFoto; // Adicionado
  final bool favorito;

  const Filme({
    this.id,
    required this.usuarioId,
    required this.titulo,
    required this.tipo,
    required this.genero,
    required this.anoLancamento,
    required this.status,
    required this.nota,
    this.dataAssistido,
    this.comentario = '',
    this.caminhoFoto,
    this.favorito = false,
  });

  /// Cria uma cópia do objeto alterando apenas os campos informados.
  Filme copyWith({
    int? id,
    int? usuarioId,
    String? titulo,
    TipoTitulo? tipo,
    String? genero,
    int? anoLancamento,
    StatusTitulo? status,
    double? nota,
    DateTime? dataAssistido,
    String? comentario,
    String? caminhoFoto,
    bool? favorito,
  }) {
    return Filme(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      genero: genero ?? this.genero,
      anoLancamento: anoLancamento ?? this.anoLancamento,
      status: status ?? this.status,
      nota: nota ?? this.nota,
      dataAssistido: dataAssistido ?? this.dataAssistido,
      comentario: comentario ?? this.comentario,
      caminhoFoto: caminhoFoto ?? this.caminhoFoto,
      favorito: favorito ?? this.favorito,
    );
  }

  /// Converte o objeto Dart em Map para salvar no SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'titulo': titulo,
      'tipo': tipo.valorBanco,
      'genero': genero,
      'anoLancamento': anoLancamento,
      'status': status.valorBanco,
      'nota': nota,
      'dataAssistido': dataAssistido?.toIso8601String(),
      'comentario': comentario,
      'caminhoFoto': caminhoFoto,
      'favorito': favorito ? 1 : 0,
    };
  }

  /// Reconstrói o objeto Dart a partir de uma linha do SQLite.
  factory Filme.fromMap(Map<String, Object?> map) {
    return Filme(
      id: map['id'] as int?,
      usuarioId: map['usuarioId'] as int? ?? 0,
      titulo: map['titulo'] as String? ?? '',
      tipo: TipoTitulo.fromBanco(map['tipo'] as String? ?? ''),
      genero: map['genero'] as String? ?? '',
      anoLancamento: map['anoLancamento'] as int? ?? DateTime.now().year,
      status: StatusTitulo.fromBanco(map['status'] as String? ?? ''),
      nota: (map['nota'] as num? ?? 0.0).toDouble(),
      dataAssistido: map['dataAssistido'] != null 
          ? DateTime.tryParse(map['dataAssistido'] as String) 
          : null,
      comentario: map['comentario'] as String? ?? '',
      caminhoFoto: map['caminhoFoto'] as String?,
      favorito: (map['favorito'] as int? ?? 0) == 1,
    );
  }
}
