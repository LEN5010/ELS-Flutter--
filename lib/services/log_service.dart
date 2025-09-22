import '../core/api_client.dart';
import '../models/log.dart';

class LogService {
  static final ApiClient _api = ApiClient();

  // 获取我的活动日志
  static Future<LogsResponse> getMyLogs({int page = 1, int perPage = 20}) async {
    final data = await _api.get('/logs/my-logs', query: {
      'page': page,
      'per_page': perPage,
    });
    return LogsResponse.fromJson(data);
  }

  // 获取指定用户的活动日志（管理员）
  static Future<LogsResponse> getUserLogs(int userId, {int page = 1, int perPage = 20}) async {
    final data = await _api.get('/logs/user/$userId/logs', query: {
      'page': page,
      'per_page': perPage,
    });
    return LogsResponse.fromJson(data);
  }

  // 根据操作类型获取日志（管理员）
  static Future<LogsResponse> getLogsByAction(String actionType, {int page = 1, int perPage = 20}) async {
    final data = await _api.get('/logs/by-action/$actionType', query: {
      'page': page,
      'per_page': perPage,
    });
    return LogsResponse.fromJson(data);
  }

  // 根据日期范围获取日志（管理员）
  static Future<LogsResponse> getLogsByDateRange({
    required String startDate,
    required String endDate,
    int? userId,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = {
      'start_date': startDate,
      'end_date': endDate,
      'page': page,
      'per_page': perPage,
    };
    if (userId != null) {
      query['user_id'] = userId;
    }
    final data = await _api.get('/logs/by-date-range', query: query);
    return LogsResponse.fromJson(data);
  }

  // 获取日志统计（管理员）
  static Future<LogStatistics> getLogStatistics({String? startDate, String? endDate}) async {
    final query = <String, dynamic>{};
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;

    final data = await _api.get('/logs/statistics', query: query.isNotEmpty ? query : null);
    return LogStatistics.fromJson(data);
  }

  // 手动创建日志
  static Future<void> createLog({
    required String actionType,
    required Map<String, dynamic> details,
  }) async {
    await _api.post('/logs/create', body: {
      'action_type': actionType,
      'details': details,
    });
  }

  // 记录测验尝试日志
  static Future<void> logQuizAttempt({
    required int quizId,
    required String quizTitle,
    required int score,
    required double accuracy,
  }) async {
    await _api.post('/logs/log-quiz-attempt', body: {
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'score': score,
      'accuracy': accuracy,
    });
  }

  // 记录学习进度日志
  static Future<void> logLearningProgress({
    required String contentType,
    required int contentId,
    required String action,
  }) async {
    await _api.post('/logs/log-learning-progress', body: {
      'content_type': contentType,
      'content_id': contentId,
      'action': action,
    });
  }

  // 获取最近活动
  static Future<RecentActivitiesResponse> getRecentActivities({int limit = 10}) async {
    final data = await _api.get('/logs/recent-activities', query: {
      'limit': limit,
    });
    return RecentActivitiesResponse.fromJson(data);
  }

  // 获取所有操作类型列表
  static List<String> getActionTypes() {
    return [
      'user_login',
      'user_logout',
      'quiz_attempt',
      'learning_progress',
      'post_created',
      'comment_created',
      'admin_action',
    ];
  }

  // 获取操作类型的显示名称
  static String getActionTypeDisplay(String actionType) {
    switch (actionType) {
      case 'user_login':
        return '用户登录';
      case 'user_logout':
        return '用户登出';
      case 'quiz_attempt':
        return '测验尝试';
      case 'learning_progress':
        return '学习进度';
      case 'post_created':
        return '帖子创建';
      case 'comment_created':
        return '评论创建';
      case 'admin_action':
        return '管理员操作';
      default:
        return actionType;
    }
  }
}