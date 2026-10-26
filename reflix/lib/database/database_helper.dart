import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Única porta de entrada para o banco. Todos os DAOs usam esta conexão.
class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  // Suba esse número sempre que alterar o schema abaixo.
  static const int _version = 5;
  static const String _dbName = 'app_filmes.db';
  static const String tableFilmes = 'filmes';
  static const String tableUsuarios = 'usuarios';
  static const String tableLembretes = 'lembretes';

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createFilmes(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS $tableFilmes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuarioId INTEGER NOT NULL,
      titulo TEXT NOT NULL,
      tipo TEXT NOT NULL,
      genero TEXT NOT NULL,
      anoLancamento INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'assistido',
      nota REAL NOT NULL,
      dataAssistido TEXT,
      comentario TEXT,
      caminhoFoto TEXT,
      favorito INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (usuarioId) REFERENCES $tableUsuarios (id)
    )
  ''');

  Future<void> _createUsuarios(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS $tableUsuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      senhaHash TEXT NOT NULL
    )
  ''');

  Future<void> _createLembretes(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS $tableLembretes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuarioId INTEGER NOT NULL,
      filmeId INTEGER NOT NULL,
      dataLembrete TEXT NOT NULL,
      mensagem TEXT,
      FOREIGN KEY (usuarioId) REFERENCES $tableUsuarios (id),
      FOREIGN KEY (filmeId) REFERENCES $tableFilmes (id) ON DELETE CASCADE
    )
  ''');

  Future<void> _createDb(Database db, int version) async {
    await _createUsuarios(db);
    await _createFilmes(db);
    await _createLembretes(db);
  }

  // v3: recria a tabela filmes
  // v4: adiciona a coluna caminhoFoto
  // v5: cria a tabela lembretes
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    await _createUsuarios(db);
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS $tableFilmes');
      await _createFilmes(db);
    } else if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableFilmes ADD COLUMN caminhoFoto TEXT');
    }
    await _createLembretes(db);
  }

  // Útil em desenvolvimento: apaga o banco físico do dispositivo.
  Future<void> resetDatabaseForDev() async {
    final path = join(await getDatabasesPath(), _dbName);
    await _database?.close();
    await deleteDatabase(path);
    _database = null;
  }

  Future<void> salvarImagem(String url) async {
    final db = await _initDatabase();
    await db.insert('tabela', {'foto': url}); 
  }
}
