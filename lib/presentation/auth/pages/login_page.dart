import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'pluxee@teste.com');
  final _password = TextEditingController(text: '123456');

  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _email.text.trim(),
          password: _password.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth > 700;
            final card = Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Entrar',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'E-mail',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Informe um e-mail válido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => AppButton(
                          label: 'Entrar',
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : _submit,
                          loading: state.status == AuthStatus.loading,
                          icon: Icons.login,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Não tem conta? Cadastre-se'),
                      ),
                    ],
                  ),
                ),
              ),
            );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 480 : 360),
                child: Padding(padding: const EdgeInsets.all(16), child: card),
              ),
            );
          },
        ),
      ),
    );
  }
}
