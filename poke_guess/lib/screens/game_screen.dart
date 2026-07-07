import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/guess.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TextEditingController? _autoCompleteController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).startNewGame();
    });
  }

  Color _getComparisonColor(Comparison comp) {
    switch (comp) {
      case Comparison.correct:
        return Colors.green;
      case Comparison.partial:
        return Colors.yellow.shade700;
      case Comparison.incorrect:
      case Comparison.higher:
      case Comparison.lower:
        return Colors.red;
    }
  }

  String _getArrow(Comparison comp) {
    if (comp == Comparison.higher) return ' ↑';
    if (comp == Comparison.lower) return ' ↓';
    return '';
  }

  Widget _buildAttributeBox(String label, String value, Comparison comp) {
    return Container(
      width: 70,
      height: 60,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: _getComparisonColor(comp),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value${_getArrow(comp)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'POKE GUESS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    'Wins: ${provider.wins} 🏆',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: provider.startNewGame,
                  icon: const Icon(Icons.catching_pokemon),
                  label: const Text('GERAR POKÉMON'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return provider.pokemonList.where((String option) {
                      return option.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    provider.makeGuess(selection);
                    _autoCompleteController?.clear();
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    _autoCompleteController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Digite o nome do Pokémon',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: provider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: provider.hasWon
                                    ? null
                                    : () {
                                        provider.makeGuess(controller.text);
                                        controller.clear();
                                      },
                              ),
                        errorText: provider.errorMessage,
                      ),
                      onSubmitted: (value) {
                        if (!provider.hasWon) {
                          provider.makeGuess(value);
                          controller.clear();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.guesses.length,
                    itemBuilder: (context, index) {
                      final guess = provider.guesses[index];
                      final pokemon = guess.guessedPokemon;

                      List<String> displayTypes = List.from(pokemon.types);
                      if (displayTypes.length == 1) {
                        displayTypes.add(displayTypes[0]);
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.network(pokemon.spriteUrl, width: 60, height: 60,
                                    errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    pokemon.name.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildAttributeBox('Tipo 1', displayTypes[0].toUpperCase(), guess.type1Comparison),
                                  _buildAttributeBox('Tipo 2', displayTypes[1].toUpperCase(), guess.type2Comparison),
                                  _buildAttributeBox('Gen', pokemon.generation.toString(), guess.genComparison),
                                  _buildAttributeBox('Altura', '${pokemon.heightMeter}m', guess.heightComparison),
                                  _buildAttributeBox('Peso', '${pokemon.weightKg}kg', guess.weightComparison),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}