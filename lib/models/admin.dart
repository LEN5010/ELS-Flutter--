// lib/models/admin.dart

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final i = int.tryParse(v);
    if (i != null) return i;
    final d = double.tryParse(v);
    if (d != null) return d.toInt();
  }
  return 0;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) {
    final d = double.tryParse(v);
    if (d != null) return d;
    final i = int.tryParse(v);
    if (i != null) return i.toDouble();
  }
  return 0.0;
}

class AdminUser {
  final int userId;
  final String email;
  final String createdAt;
  final String nickname;
  final String gender;
  final String role;
  final int? vocabLearned;
  final int? grammarLearned;
  final int? listeningDone;

  AdminUser({
    required this.userId,
    required this.email,
    required this.createdAt,
    required this.nickname,
    required this.gender,
    required this.role,
    this.vocabLearned,
    this.grammarLearned,
    this.listeningDone,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        userId: _asInt(j['user_id']),
        email: j['email']?.toString() ?? '',
        createdAt: j['created_at']?.toString() ?? '',
        nickname: j['nickname']?.toString() ?? '',
        gender: j['gender']?.toString() ?? 'U',
        role: j['role']?.toString() ?? 'student',
        vocabLearned: j['vocab_learned'] == null ? null : _asInt(j['vocab_learned']),
        grammarLearned: j['grammar_learned'] == null ? null : _asInt(j['grammar_learned']),
        listeningDone: j['listening_done'] == null ? null : _asInt(j['listening_done']),
      );
}

class AdminUserSummary {
  final int totalUsers;
  final int adminCount;
  final int studentCount;
  AdminUserSummary({required this.totalUsers, required this.adminCount, required this.studentCount});
  factory AdminUserSummary.fromJson(Map<String, dynamic> j) => AdminUserSummary(
        totalUsers: _asInt(j['total_users']),
        adminCount: _asInt(j['admin_count']),
        studentCount: _asInt(j['student_count']),
      );
}

class PostsSummary {
  final int totalPosts;
  final int pendingPosts;
  final int approvedPosts;
  PostsSummary({required this.totalPosts, required this.pendingPosts, required this.approvedPosts});
  factory PostsSummary.fromJson(Map<String, dynamic> j) => PostsSummary(
        totalPosts: _asInt(j['total_posts']),
        pendingPosts: _asInt(j['pending_posts']),
        approvedPosts: _asInt(j['approved_posts']),
      );
}

class AdminStatistics {
  final AdminUserSummary users;
  final int vocabCount;
  final int grammarCount;
  final int listeningCount;
  final int quizCount;
  final int quizAttempts;
  final PostsSummary posts;
  final int commentCount;
  final int todayUsers;

  AdminStatistics({
    required this.users,
    required this.vocabCount,
    required this.grammarCount,
    required this.listeningCount,
    required this.quizCount,
    required this.quizAttempts,
    required this.posts,
    required this.commentCount,
    required this.todayUsers,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> j) => AdminStatistics(
        users: AdminUserSummary.fromJson(j['users'] ?? {}),
        vocabCount: _asInt(j['vocab_count']),
        grammarCount: _asInt(j['grammar_count']),
        listeningCount: _asInt(j['listening_count']),
        quizCount: _asInt(j['quiz_count']),
        quizAttempts: _asInt(j['quiz_attempts']),
        posts: PostsSummary.fromJson(j['posts'] ?? {}),
        commentCount: _asInt(j['comment_count']),
        todayUsers: _asInt(j['today_users']),
      );
}

class QuizPerformance {
  final int quizId;
  final String title;
  final String quizType;
  final int attemptCount;
  final double? avgScore;
  final int? maxScore;
  final int? minScore;
  final double avgAccuracy;

  QuizPerformance({
    required this.quizId,
    required this.title,
    required this.quizType,
    required this.attemptCount,
    this.avgScore,
    this.maxScore,
    this.minScore,
    required this.avgAccuracy,
  });

  factory QuizPerformance.fromJson(Map<String, dynamic> j) => QuizPerformance(
        quizId: _asInt(j['quiz_id']),
        title: j['title']?.toString() ?? '',
        quizType: j['quiz_type']?.toString() ?? '',
        attemptCount: _asInt(j['attempt_count']),
        avgScore: j['avg_score'] == null ? null : _asDouble(j['avg_score']),
        maxScore: j['max_score'] == null ? null : _asInt(j['max_score']),
        minScore: j['min_score'] == null ? null : _asInt(j['min_score']),
        avgAccuracy: _asDouble(j['avg_accuracy']),
      );
}

class UserProgressStats {
  final double avgVocab;
  final double avgGrammar;
  final double avgListening;
  final int maxVocab;
  final int maxGrammar;
  final int maxListening;
  final int activeUsers7days;

  UserProgressStats({
    required this.avgVocab,
    required this.avgGrammar,
    required this.avgListening,
    required this.maxVocab,
    required this.maxGrammar,
    required this.maxListening,
    required this.activeUsers7days,
  });

  factory UserProgressStats.fromJson(Map<String, dynamic> j) => UserProgressStats(
        avgVocab: _asDouble(j['avg_vocab']),
        avgGrammar: _asDouble(j['avg_grammar']),
        avgListening: _asDouble(j['avg_listening']),
        maxVocab: _asInt(j['max_vocab']),
        maxGrammar: _asInt(j['max_grammar']),
        maxListening: _asInt(j['max_listening']),
        activeUsers7days: _asInt(j['active_users_7days']),
      );
}