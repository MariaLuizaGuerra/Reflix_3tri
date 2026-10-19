import 'package:app_filmes/model/filme_model.dart';
import 'package:app_filmes/database/database_helper.dart';
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
      whereArgs: [usuarioId, status.name],
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

}
