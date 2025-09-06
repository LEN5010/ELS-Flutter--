class QuizItem {
  final int quizId;
  final String quizType;
  final String title;
  final int totalPoints;

  QuizItem({
    required this.quizId,
    required this.quizType,
    required this.title,
    required this.totalPoints,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) => QuizItem(
        quizId: json['quiz_id'],
        quizType: json['quiz_type'],
        title: json['title'],
        totalPoints: json['total_points'],
      );
}

class QuizMeta {
  final int quizId;
  final String quizType;
  final String title;
  final int totalPoints;

  QuizMeta({
    required this.quizId,
    required this.quizType,
    required this.title,
    required this.totalPoints,
  });

  factory QuizMeta.fromJson(Map<String, dynamic> json) => QuizMeta(
        quizId: json['quiz_id'],
        quizType: json['quiz_type'],
        title: json['title'],
        totalPoints: json['total_points'],
      );
}

class Question {
  final int questionId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int score;

  Question({
    required this.questionId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.score,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        questionId: json['question_id'],
        question: json['question'],
        optionA: json['option_a'],
        optionB: json['option_b'],
        optionC: json['option_c'],
        optionD: json['option_d'],
        score: json['score'],
      );
}

class QuizResult {
  final int score;
  final int correctCount;
  final int totalCount;
  final double accuracy;
  final String level;

  QuizResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.accuracy,
    required this.level,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        score: json['score'],
        correctCount: json['correct_count'],
        totalCount: json['total_count'],
        accuracy: (json['accuracy'] as num).toDouble(),
        level: json['level'],
      );
}