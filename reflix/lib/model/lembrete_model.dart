class Lembrete {
  final int? id;
  final int usuarioId;
  final int filmeId;
  final DateTime dataLembrete;
  final String mensagem;

  const Lembrete({
    this.id,
    required this.usuarioId,
    required this.filmeId,
    required this.dataLembrete,
    this.mensagem = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'usuarioId': usuarioId,
        'filmeId': filmeId,
        'dataLembrete': dataLembrete.toIso8601String(),
        'mensagem': mensagem,
      };

  factory Lembrete.fromMap(Map<String, Object?> map) {
    return Lembrete(
      id: map['id'] as int?,
      usuarioId: map['usuarioId'] as int,
      filmeId: map['filmeId'] as int,
      dataLembrete: DateTime.parse(map['dataLembrete'] as String),
      mensagem: map['mensagem'] as String? ?? '',
    );
  }
}
