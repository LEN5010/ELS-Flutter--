class GrammarItem {
  final int grammarId;
  final String title;
  final String content;
  final String level;

  GrammarItem({
    required this.grammarId,
    required this.title,
    required this.content,
    required this.level,
  });

  factory GrammarItem.fromJson(Map<String, dynamic> json) => GrammarItem(
        grammarId: json['grammar_id'],
        title: json['title'],
        content: json['content'],
        level: json['level'],
      );
}