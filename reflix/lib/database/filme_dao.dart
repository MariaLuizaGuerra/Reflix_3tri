import 'package:app_filmes/model/filme_model.dart';
import 'package:app_filmes/database/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Mantém o SQL isolado do resto do app (boa prática de camadas).
class FilmeDao {
  static const String _nomeTabela = DatabaseHelper.tableFilmes;

  Future<Database> get database => DatabaseHelper.instance.database;

  // ---------- CREATE ----------
  Future<int> add(Filme filme) async {
    final db = await database;
    return await db.insert(_nomeTabela, filme.toMap());
  }

  // ---------- READ ----------
  Future<List<Filme>> listarTodos() async {
    final db = await database;
    final resultado = await db.query(_nomeTabela, orderBy: 'titulo ASC');
    return resultado.map((linha) => Filme.fromMap(linha)).toList();
  }

  Future<List<Filme>> listarPorUsuario(int usuarioId, StatusTitulo status) async {
    final db = await database;
    final resultado = await db.query(
      _nomeTabela,
      where: 'usuarioId = ? AND status = ?',
      whereArgs: [usuarioId, status.valorBanco],
      orderBy: 'id DESC',
    );
    return resultado.map((linha) => Filme.fromMap(linha)).toList();
  }

  Future<Filme?> buscarPorId(int id) async {
    final db = await database;
    final resultado = await db.query(
      _nomeTabela,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (resultado.isEmpty) return null;
    return Filme.fromMap(resultado.first);
  }

  // ---------- UPDATE (tela de edição) ----------
  Future<int> atualizar(Filme filme) async {
    final db = await database;
    return db.update(
      _nomeTabela,
      filme.toMap(),
      where: 'id = ?',
      whereArgs: [filme.id],
    );
  }

  // ---------- UPDATE (só o flag favorito) ----------
  Future<int> alternarFavorito(int id, bool novoValor) async {
    final db = await database;
    return db.update(
      _nomeTabela,
      {'favorito': novoValor ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- DELETE ----------
  Future<int> remover(int id) async {
    final db = await database;
    return db.delete(_nomeTabela, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- MÉTODOS TRATADOS PARA O DASHBOARD ----------
  // Usam StatusTitulo.assistido.valorBanco (o mesmo valor do listarPorUsuario),
  // em vez do texto fixo 'assistido', para nunca ficarem fora de sincronia.

  /// Conta a quantidade total de títulos assistidos por um usuário.
  Future<int> contarAssistidos(int usuarioId) async {
    try {
      final db = await database;
      final resultado = await db.rawQuery(
        'SELECT COUNT(*) as total FROM $_nomeTabela WHERE usuarioId = ? AND status = ?',
        [usuarioId, StatusTitulo.assistido.valorBanco],
      );
      return Sqflite.firstIntValue(resultado) ?? 0;
    } catch (e, st) {
      debugPrint('ERRO contarAssistidos: $e\n$st');
      return 0;
    }
  }

  /// Retorna o nome do gênero mais assistido e a quantidade de títulos dele.
  Future<Map<String, Object?>?> generoFavorito(int usuarioId) async {
    try {
      final db = await database;
      final resultado = await db.rawQuery('''
        SELECT genero, COUNT(*) as total
        FROM $_nomeTabela
        WHERE usuarioId = ? AND status = ? AND genero IS NOT NULL
        GROUP BY genero
        ORDER BY total DESC, AVG(nota) DESC
        LIMIT 1
      ''', [usuarioId, StatusTitulo.assistido.valorBanco]);

      if (resultado.isEmpty) return null;
      return resultado.first;
    } catch (e, st) {
      debugPrint('ERRO generoFavorito: $e\n$st');
      return null;
    }
  }

  /// Calcula a média aritmética das notas dadas pelo usuário (maiores que zero).
  Future<double?> mediaGeral(int usuarioId) async {
    try {
      final db = await database;
      final resultado = await db.rawQuery(
        'SELECT AVG(nota) as media FROM $_nomeTabela WHERE usuarioId = ? AND status = ? AND nota > 0',
        [usuarioId, StatusTitulo.assistido.valorBanco],
      );
      if (resultado.isEmpty) return null;
      final media = resultado.first['media'];
      return media != null ? (media as num).toDouble() : null;
    } catch (e, st) {
      debugPrint('ERRO mediaGeral: $e\n$st');
      return null;
    }
  }

  /// Agrupa as visualizações processando as strings de data de forma segura no Dart.
  Future<Map<String, int>> assistidosPorMes(int usuarioId) async {
    final mapa = <String, int>{};
    try {
      final db = await database;
      final resultado = await db.query(
        _nomeTabela,
        columns: ['dataAssistido'],
        where: 'usuarioId = ? AND status = ? AND dataAssistido IS NOT NULL',
        whereArgs: [usuarioId, StatusTitulo.assistido.valorBanco],
      );

      for (final linha in resultado) {
        final dataStr = linha['dataAssistido'] as String?;
        if (dataStr != null) {
          final dataParsed = DateTime.tryParse(dataStr);
          if (dataParsed != null) {
            // Chave no formato esperado pela tela: "ANO-MES" (ex: 2026-10)
            final chave =
                '${dataParsed.year}-${dataParsed.month.toString().padLeft(2, '0')}';
            mapa[chave] = (mapa[chave] ?? 0) + 1;
          }
        }
      }
    } catch (e, st) {
      debugPrint('ERRO assistidosPorMes: $e\n$st');
    }
    return mapa;
  }
}
