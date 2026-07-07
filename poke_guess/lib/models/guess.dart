import 'pokemon.dart';

enum Comparison { correct, lower, higher, incorrect, partial }

class Guess {
  final Pokemon guessedPokemon;
  final bool isCorrect;
  final Comparison type1Comparison;
  final Comparison type2Comparison;
  final Comparison heightComparison;
  final Comparison weightComparison;
  final Comparison genComparison;

  Guess({
    required this.guessedPokemon,
    required this.isCorrect,
    required this.type1Comparison,
    required this.type2Comparison,
    required this.heightComparison,
    required this.weightComparison,
    required this.genComparison,
  });
}