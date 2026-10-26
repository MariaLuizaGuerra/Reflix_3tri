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

  Future<ResultadoAuth> atualizar({
    required int id,
    required String nome,
    required String email,
  }) async {
    final db = await database;
    final emailNormalizado = email.trim().toLowerCase();

    final outros = await db.query(
      _nomeTabela,
      where: 'email = ? AND id != ?',
      whereArgs: [emailNormalizado, id],
    );
    if (outros.isNotEmpty) return ResultadoAuth.emailJaCadastrado;

    await db.update(
      _nomeTabela,
      {'nome': nome.trim(), 'email': emailNormalizado},
      where: 'id = ?',
      whereArgs: [id],
    );
    return ResultadoAuth.sucesso;
  }

    // Código Corrigido no seu usuario_dao.dart
  Future<void> excluirConta(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      // ❌ REMOVA ESTA LINHA ABAIXO (A tabela tableLembretes não existe no seu DatabaseHelper):
      // await txn.delete(DatabaseHelper.tableLembretes, where: 'usuarioId = ?', whereArgs: [id]);
      
      // Mantenha apenas estas:
      await txn.delete(DatabaseHelper.tableFilmes, where: 'usuarioId = ?', whereArgs: [id]);
      await txn.delete(_nomeTabela, where: 'id = ?', whereArgs: [id]);
    });
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
