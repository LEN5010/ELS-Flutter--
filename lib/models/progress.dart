class Progress {
  final int userId;
  final int vocabLearned;
  final int grammarLearned;
  final int listeningDone;
  final String lastUpdate;

  Progress({
    required this.userId,
    required this.vocabLearned,
    required this.grammarLearned,
    required this.listeningDone,
    required this.lastUpdate,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        userId: json['user_id'],
        vocabLearned: json['vocab_learned'],
        grammarLearned: json['grammar_learned'],
        listeningDone: json['listening_done'],
        lastUpdate: json['last_update'],
      );
}

class QuizHistoryItem {
  final int resultId;
  final int quizId;
  final String title;
  final String quizType;
  final int score;
  final int correctCnt;
  final int totalCnt;
  final String takenAt;

  QuizHistoryItem({
    required this.resultId,
    required this.quizId,
    required this.title,
    required this.quizType,
    required this.score,
    required this.correctCnt,
    required this.totalCnt,
    required this.takenAt,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) => QuizHistoryItem(
        resultId: json['result_id'],
        quizId: json['quiz_id'],
        title: json['title'],
        quizType: json['quiz_type'],
        score: json['score'],
        correctCnt: json['correct_cnt'],
        totalCnt: json['total_cnt'],
        takenAt: json['taken_at'],
      );
}