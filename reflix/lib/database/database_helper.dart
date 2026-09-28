import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  // Suba esse número sempre que alterar o CREATE TABLE abaixo.
  static const int _version = 1;
  static const String _dbName = 'app_filmes.db';
  static const String _tableFilmes = 'filmes';

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableFilmes (
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

  

  // Útil em desenvolvimento, quando o schema muda e você não quer
  // lidar com migração ainda: apaga o banco físico do dispositivo.
  Future<void> resetDatabaseForDev() async {
    String path = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
