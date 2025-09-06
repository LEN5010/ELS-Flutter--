class ListeningItem {
  final int listenId;
  final String title;
  final String audioUrl;
  final String transcript;
  final String level;

  ListeningItem({
    required this.listenId,
    required this.title,
    required this.audioUrl,
    required this.transcript,
    required this.level,
  });

  factory ListeningItem.fromJson(Map<String, dynamic> json) => ListeningItem(
        listenId: json['listen_id'],
        title: json['title'],
        audioUrl: json['audio_url'],
        transcript: json['transcript'] ?? '',
        level: json['level'],
      );
}