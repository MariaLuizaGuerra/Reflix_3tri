import 'package:app_filmes/database/database_helper.dart';
import 'package:app_filmes/model/lembrete_model.dart';
import 'package:sqflite/sqflite.dart';

class LembreteDao {
  static const String _nomeTabela = DatabaseHelper.tableLembretes;

  Future<Database> get database => DatabaseHelper.instance.database;

  Future<int> add(Lembrete lembrete) async {
    final db = await database;
    return await db.insert(_nomeTabela, lembrete.toMap()..remove('id'));
  }

  Future<Lembrete?> buscarPorFilme(int filmeId) async {
    final db = await database;
    final resultado = await db.query(
      _nomeTabela,
      where: 'filmeId = ?',
      whereArgs: [filmeId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return Lembrete.fromMap(resultado.first);
  }

  Future<int> atualizar(Lembrete lembrete) async {
    final db = await database;
    return db.update(
      _nomeTabela,
      lembrete.toMap(),
      where: 'id = ?',
      whereArgs: [lembrete.id],
    );
  }

  Future<int> removerPorFilme(int filmeId) async {
    final db = await database;
    return db.delete(_nomeTabela, where: 'filmeId = ?', whereArgs: [filmeId]);
  }
}
