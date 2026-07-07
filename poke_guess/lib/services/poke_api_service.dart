import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<Pokemon?> getPokemon(String query) async {
    try {
      final formattedQuery = query.trim().toLowerCase();
      final response = await http.get(Uri.parse('$_baseUrl/$formattedQuery'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  int getRandomPokemonId({int maxGeneration = 1}) {
    final random = Random();
    int maxId;

    switch (maxGeneration) {
      case 1: maxId = 151; break;
      case 2: maxId = 251; break;
      case 3: maxId = 386; break;
      case 4: maxId = 493; break;
      default: maxId = 151;
    }

    return random.nextInt(maxId) + 1;
  }

  Future<List<String>> getAllPokemonNames() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?limit=1000'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).map((e) => e['name'] as String).toList();
      }
    } catch (e) {
      print('Erro ao buscar lista de nomes: $e');
    }
    return [];
  }
}