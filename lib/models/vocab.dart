class VocabItem {
  final int wordId;
  final String word;
  final String meaning;
  final String example;
  final String level;

  VocabItem({
    required this.wordId,
    required this.word,
    required this.meaning,
    required this.example,
    required this.level,
  });

  factory VocabItem.fromJson(Map<String, dynamic> json) => VocabItem(
        wordId: json['word_id'],
        word: json['word'],
        meaning: json['meaning'],
        example: json['example'] ?? '',
        level: json['level'] ?? '',
      );
}