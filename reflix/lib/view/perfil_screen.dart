import 'package:app_filmes/database/usuario_dao.dart';
import 'package:app_filmes/model/usuario_model.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioDao _dao = UsuarioDao();

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;

  final _regexEmail = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _emailController = TextEditingController(text: widget.usuario.email);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final resultado = await _dao.atualizar(
      id: widget.usuario.id!,
      nome: _nomeController.text,
      email: _emailController.text,
    );

    if (!mounted) return;
    setState(() => _salvando = false);

    if (resultado == ResultadoAuth.emailJaCadastrado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse e-mail já está em uso.')),
      );
      return;
    }

    final atualizado = Usuario(
      id: widget.usuario.id,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      senhaHash: widget.usuario.senhaHash,
    );
    Navigator.pop(context, atualizado);
  }

  Future<void> _confirmarExclusao() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Isso apaga sua conta, seus títulos e seus lembretes. Não dá para desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await _dao.excluirConta(widget.usuario.id!);
    if (!mounted) return;
    Navigator.pop(context, 'excluida');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!_regexEmail.hasMatch(valor.trim())) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Salvar alterações'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _confirmarExclusao,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: const BorderSide(color: Color(0xFF2B2B2B)),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
