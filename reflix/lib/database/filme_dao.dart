import 'package:app_filmes/model/filme_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Mantém o SQL isolado do resto do app (boa prática de camadas).
class FilmeDao {
  static const String _nomeTabela = 'filmes';
  static Database? _database;

  // Singleton simples: reaproveita a mesma conexão em todo o app.
  Future<Database> get database async {
    _database ??= await _iniciarBanco();
    return _database!;
  }

  Future<Database> _iniciarBanco() async {
    final caminho = join(await getDatabasesPath(), 'app_filmes.db');
    return openDatabase(
      caminho,
      version: 1, // volte pra 1: se o banco no dispositivo ainda está
      // na v1 (schema antigo com dataAssistido), o onUpgrade não roda
      // porque o app "acha" que já está atualizado. Ver instruções abaixo.
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_nomeTabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        tipo TEXT NOT NULL,
        genero TEXT NOT NULL,
        anoLancamento INTEGER NOT NULL,
        nota REAL NOT NULL,
        comentario TEXT,
        favorito INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Exemplo de como migrar no futuro, se precisar adicionar coluna:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $_nomeTabela ADD COLUMN novaColuna TEXT');
    // }
  }

  // Atalho de desenvolvimento: apaga o banco físico do dispositivo,
  // forçando o onCreate a rodar de novo com o schema atual.
  Future<void> resetDatabaseForDev() async {
    final caminho = join(await getDatabasesPath(), 'app_filmes.db');
    await deleteDatabase(caminho);
    _database = null;
  }

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
