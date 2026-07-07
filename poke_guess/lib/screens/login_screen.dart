import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Preencha todos os campos', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final userData = await _authService.login(
      _userController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (userData != null) {
      if (mounted) {
        Provider.of<GameProvider>(context, listen: false).setLoggedInUser(
          userData['username'],
          userData['wins'],
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      }
    } else {
      _showSnackBar('Credenciais inválidas ou servidor offline', isError: true);
    }
  }

  Future<void> _handleCadastro() async {
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Preencha todos os campos', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final sucesso = await _authService.cadastrar(
      _userController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (sucesso) {
      _showSnackBar('Usuário cadastrado com sucesso! Faça o login.');
    } else {
      _showSnackBar('Erro ao cadastrar. Usuário já existe?', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.catching_pokemon, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'POKE GUESS',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Entrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleCadastro,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}