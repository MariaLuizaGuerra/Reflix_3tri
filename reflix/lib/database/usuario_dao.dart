import 'package:app_filmes/model/usuario_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app_filmes/database/database_helper.dart';

enum ResultadoAuth { sucesso, emailJaCadastrado, credenciaisInvalidas }

class UsuarioDao {
  static const String _nomeTabela = DatabaseHelper.tableUsuarios;

  Future<Database> get database => DatabaseHelper.instance.database;

  /// Verifica se já existe algum usuário com esse e-mail.
  Future<bool> _emailExiste(String email) async {
    final db = await database;
    final resultado = await db.query(
      _nomeTabela,
      where: 'email = ?',
      whereArgs: [email],
    );
    return resultado.isNotEmpty;
  }
  Future<ResultadoAuth> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    if (await _emailExiste(emailNormalizado)) {
      return ResultadoAuth.emailJaCadastrado;
    }

    final db = await database;
    final usuario = Usuario(
      nome: nome.trim(),
      email: emailNormalizado,
      senhaHash: Usuario.gerarHash(senha),
    );
    await db.insert(_nomeTabela, usuario.toMap()..remove('id'));
    return ResultadoAuth.sucesso;
  }

  Future<Usuario?> autenticar({
    required String email,
    required String senha,
  }) async {
    final db = await database;
    final hashDigitado = Usuario.gerarHash(senha);
    final emailNormalizado = email.trim().toLowerCase();

    final resultado = await db.query(
      _nomeTabela,
      where: 'email = ? AND senhaHash = ?',
      whereArgs: [emailNormalizado, hashDigitado],
    );

    if (resultado.isEmpty) return null;
    return Usuario.fromMap(resultado.first);
  }
}
