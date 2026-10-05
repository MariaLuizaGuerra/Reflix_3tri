import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Entidade de usuário do aplicativo.
/// IMPORTANTE: nunca guardamos a senha em texto puro, apenas o hash dela.
class Usuario {
  final int? id; // chave primária
  final String nome;
  final String email;
  final String senhaHash; // resultado do SHA-256, nunca a senha original

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
  });

  /// Gera o hash SHA-256 de uma senha em texto puro.
  /// Usado tanto no cadastro (para salvar) quanto no login (para comparar).
  static String gerarHash(String senhaTextoPuro) {
    final bytes = utf8.encode(senhaTextoPuro);
    return sha256.convert(bytes).toString();
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senhaHash': senhaHash,
    };
  }

  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senhaHash: map['senhaHash'] as String,
    );
  }
}
