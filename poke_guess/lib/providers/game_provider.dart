import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/guess.dart';
import '../services/poke_api_service.dart';

class GameProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();
  
  Pokemon? dailyPokemon;
  List<Guess> guesses = [];
  List<String> pokemonList = [];
  bool isLoading = false;
  bool hasWon = false;
  String? errorMessage;
  int wins = 0;

  Future<void> startNewGame() async {
    isLoading = true;
    notifyListeners();

    if (pokemonList.isEmpty) {
      pokemonList = await _apiService.getAllPokemonNames();
    }

    int randomId = _apiService.getRandomPokemonId(maxGeneration: 1);
    dailyPokemon = await _apiService.getPokemon(randomId.toString());

    guesses.clear();
    hasWon = false;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  List<String> _getPaddedTypes(List<String> types) {
    List<String> padded = List.from(types);
    if (padded.length == 1) {
      padded.add(padded[0]);
    }
    return padded;
  }

  List<Comparison> _evaluateTypesWordleLogic(List<String> guessTypes, List<String> targetTypes) {
    List<Comparison> results = [Comparison.incorrect, Comparison.incorrect];
    List<String> targetPool = List.from(targetTypes);

    for (int i = 0; i < 2; i++) {
      if (guessTypes[i] == targetTypes[i]) {
        results[i] = Comparison.correct;
        targetPool.remove(guessTypes[i]);
      }
    }

    for (int i = 0; i < 2; i++) {
      if (results[i] != Comparison.correct) {
        if (targetPool.contains(guessTypes[i])) {
          results[i] = Comparison.partial;
          targetPool.remove(guessTypes[i]);
        } else {
          results[i] = Comparison.incorrect;
        }
      }
    }

    return results;
  }

  Future<void> makeGuess(String pokemonName) async {
    if (hasWon || pokemonName.isEmpty || dailyPokemon == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    Pokemon? guessed = await _apiService.getPokemon(pokemonName);

    if (guessed == null) {
      errorMessage = 'Pokémon não encontrado!';
      isLoading = false;
      notifyListeners();
      return;
    }

    List<String> guessTypes = _getPaddedTypes(guessed.types);
    List<String> targetTypes = _getPaddedTypes(dailyPokemon!.types);

    List<Comparison> typeComparisons = _evaluateTypesWordleLogic(guessTypes, targetTypes);

    final newGuess = Guess(
      guessedPokemon: guessed,
      isCorrect: guessed.id == dailyPokemon!.id,
      type1Comparison: typeComparisons[0],
      type2Comparison: typeComparisons[1],
      heightComparison: _compareNumeric(guessed.heightMeter, dailyPokemon!.heightMeter),
      weightComparison: _compareNumeric(guessed.weightKg, dailyPokemon!.weightKg),
      genComparison: _compareNumeric(guessed.generation.toDouble(), dailyPokemon!.generation.toDouble()),
    );

    guesses.insert(0, newGuess);

    if (newGuess.isCorrect) {
      hasWon = true;
      wins++;
    }

    isLoading = false;
    notifyListeners();
  }

  Comparison _compareNumeric(double guessedValue, double targetValue) {
    if (guessedValue == targetValue) {
      return Comparison.correct;
    } else if (targetValue > guessedValue) {
      return Comparison.higher;
    } else {
      return Comparison.lower;
    }
  }
}