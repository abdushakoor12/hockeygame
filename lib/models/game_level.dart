class GameLevel {
  final String name;
  final String description;
  final List<String> words;
  final int difficulty; // 1-5 stars
  final String emoji;
  final List<int> gradientColors; // For UI theming

  const GameLevel({
    required this.name,
    required this.description,
    required this.words,
    required this.difficulty,
    required this.emoji,
    required this.gradientColors,
  });
} 