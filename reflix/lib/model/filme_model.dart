/// Filme ou Série.
enum TipoTitulo {
  filme,
  serie;

  String get valorBanco => name;
  String get label => this == TipoTitulo.filme ? 'Filme' : 'Série';

  static TipoTitulo fromBanco(String valor) => TipoTitulo.values.firstWhere(
        (t) => t.valorBanco == valor,
        orElse: () => TipoTitulo.filme,
      );
}

/// Status do título: já visto (libera nota/data/comentário) ou lista de desejos.
enum StatusTitulo {
  assistido,
  paraAssistir;

  String get valorBanco => this == StatusTitulo.assistido ? 'assistido' : 'para_assistir';
  String get label => this == StatusTitulo.assistido ? 'Já assistido' : 'Para assistir';

  static StatusTitulo fromBanco(String valor) =>
      valor == 'para_assistir' ? StatusTitulo.paraAssistir : StatusTitulo.assistido;
}

class Filme {
  final int? id;
  final int usuarioId; // FK -> usuarios.id (dono do registro)
  final String titulo;
  final TipoTitulo tipo;
  final String genero;
  final int anoLancamento;
  final StatusTitulo status;
  final double nota; // 0 enquanto "para assistir"
  final DateTime? dataAssistido; // null enquanto "para assistir"
  final String comentario;
  final String? caminhoFoto; // caminho do arquivo da capa (ou null)
  final bool favorito;

  const Filme({
    this.id,
    required this.usuarioId,
    required this.titulo,
    required this.tipo,
    required this.genero,
    required this.anoLancamento,
    this.status = StatusTitulo.assistido,
    this.nota = 0,
    this.dataAssistido,
    this.comentario = '',
    this.caminhoFoto,
    this.favorito = false,
  });

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

  Map<String, Object?> toMap() => {
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

  factory Filme.fromMap(Map<String, Object?> map) {
    final data = map['dataAssistido'] as String?;
    return Filme(
      id: map['id'] as int?,
      usuarioId: map['usuarioId'] as int,
      titulo: map['titulo'] as String,
      tipo: TipoTitulo.fromBanco(map['tipo'] as String),
      genero: map['genero'] as String,
      anoLancamento: map['anoLancamento'] as int,
      status: StatusTitulo.fromBanco(map['status'] as String),
      nota: (map['nota'] as num).toDouble(),
      dataAssistido: data == null ? null : DateTime.parse(data),
      comentario: map['comentario'] as String? ?? '',
      caminhoFoto: map['caminhoFoto'] as String?,
      favorito: (map['favorito'] as int) == 1,
    );
  }
}
