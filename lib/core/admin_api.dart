import 'package:dio/dio.dart';
import '../models/paginated.dart';
import '../models/community.dart';
import '../models/vocab.dart';
import '../models/admin.dart';
import 'api_client.dart';

class AdminApi {
  static final _api = ApiClient();

  // 用户管理
  static Future<Paginated<AdminUser>> getUsers({int page = 1, int perPage = 20}) async {
    final data = await _api.get('/admin/users', query: {'page': page, 'per_page': perPage});
    return Paginated.fromJson<AdminUser>(data, (e) => AdminUser.fromJson(e));
  }

  static Future<void> updateUserRole(int userId, String role) async {
    await _api.put('/admin/users/$userId/role', body: {'role': role});
  }

  // 帖子审核
  static Future<List<PostItem>> getPendingPosts() async {
    final data = await _api.get('/admin/posts/pending');
    return (data as List).map((e) => PostItem.fromJson(e)).toList();
  }

  static Future<void> reviewPost(int postId, String status) async {
    await _api.put('/admin/posts/$postId/review', body: {'status': status});
  }

  // 学习资源 - 词汇
  static Future<int> addVocab({required String word, required String meaning, String? example, required String level}) async {
    final data = await _api.post('/admin/vocab', body: {
      'word': word, 'meaning': meaning, 'example': example ?? '', 'level': level,
    });
    return data['word_id'];
  }

  static Future<void> updateVocab(int wordId, {String? word, String? meaning, String? example, String? level}) async {
    final body = <String, dynamic>{};
    if (word != null) body['word'] = word;
    if (meaning != null) body['meaning'] = meaning;
    if (example != null) body['example'] = example;
    if (level != null) body['level'] = level;
    await _api.put('/admin/vocab/$wordId', body: body);
  }

  static Future<void> deleteVocab(int wordId) async {
    await _api.post('/admin/vocab/$wordId', query: null); // 防止误用
    await _api.delete('/admin/vocab/$wordId'); // 需要在 ApiClient 增加 delete 方法时可用
  }

  // 语法/听力新增
  static Future<int> addGrammar({required String title, required String content, required String level}) async {
    final data = await _api.post('/admin/grammar', body: {'title': title, 'content': content, 'level': level});
    return data['grammar_id'];
  }

  static Future<int> addListening({required String title, required String audioUrl, String? transcript, required String level}) async {
    final data = await _api.post('/admin/listening', body: {
      'title': title, 'audio_url': audioUrl, 'transcript': transcript ?? '', 'level': level,
    });
    return data['listen_id'];
  }

  // 测验管理
  static Future<int> createQuiz({required String quizType, required String title, required int totalPoints}) async {
    final data = await _api.post('/admin/quiz', body: {
      'quiz_type': quizType, 'title': title, 'total_points': totalPoints,
    });
    return data['quiz_id'];
  }

  static Future<int> addQuizQuestion({
    required int quizId,
    required String question,
    required String a, required String b, required String c, required String d,
    required String correct, required int score,
  }) async {
    final data = await _api.post('/admin/quiz/$quizId/questions', body: {
      'question': question, 'option_a': a, 'option_b': b, 'option_c': c, 'option_d': d,
      'correct_opt': correct, 'score': score,
    });
    return data['question_id'];
  }

  // 统计
  static Future<AdminStatistics> getStatistics() async {
    final data = await _api.get('/admin/statistics');
    return AdminStatistics.fromJson(data);
  }

  static Future<List<QuizPerformance>> getQuizPerformance() async {
    final data = await _api.get('/admin/statistics/quiz-performance');
    return (data as List).map((e) => QuizPerformance.fromJson(e)).toList();
  }

  static Future<UserProgressStats> getUserProgressStats() async {
    final data = await _api.get('/admin/statistics/user-progress');
    return UserProgressStats.fromJson(data);
  }
}