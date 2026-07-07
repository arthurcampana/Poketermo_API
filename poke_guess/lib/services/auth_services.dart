import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:8080/api/auth';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
    return null;
  }

  Future<bool> cadastrar(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

  Future<void> registrarVitoria(String username) async {
    try {
      await http.put(Uri.parse('$_baseUrl/vitoria/$username'));
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }
}