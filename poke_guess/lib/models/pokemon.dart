class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final double heightMeter; // Convertido de decímetros
  final double weightKg;    // Convertido de hectogramas
  final String spriteUrl;
  final int generation;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.heightMeter,
    required this.weightKg,
    required this.spriteUrl,
    required this.generation,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extraindo a lista de tipos do JSON complexo da PokeAPI
    var typesList = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    int id = json['id'];

    return Pokemon(
      id: id,
      name: json['name'],
      types: typesList,
      heightMeter: json['height'] / 10.0,
      weightKg: json['weight'] / 10.0,
      spriteUrl: json['sprites']['front_default'] ?? '',
      generation: _calculateGeneration(id),
    );
  }

  // Método auxiliar para evitar uma segunda chamada à API apenas para obter a Geração
  static int _calculateGeneration(int id) {
    if (id <= 151) return 1;
    if (id <= 251) return 2;
    if (id <= 386) return 3;
    if (id <= 493) return 4;
    if (id <= 649) return 5;
    if (id <= 721) return 6;
    if (id <= 809) return 7;
    if (id <= 905) return 8;
    return 9;
  }
}