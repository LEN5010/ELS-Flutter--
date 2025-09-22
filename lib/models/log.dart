import 'dart:io';

class ActivityLog {
  final String id;
  final int userId;
  final String nickname;
  final String actionType;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.actionType,
    required this.timestamp,
    required this.details,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? 0,
      nickname: json['nickname'] ?? '',
      actionType: json['action_type'] ?? '',
      timestamp: _parseTimestamp(json['timestamp']),
      details: json['details'] ?? {},
    );
  }

  static DateTime _parseTimestamp(dynamic timestampValue) {
    if (timestampValue == null) {
      return DateTime.now();
    }

    final timestampStr = timestampValue.toString();

    try {
      // 尝试解析ISO 8601格式 (e.g., "2025-09-22T06:24:22.607Z")
      return DateTime.parse(timestampStr);
    } catch (e) {
      try {
        // 尝试解析HTTP日期格式 (e.g., "Mon, 22 Sep 2025 06:24:22 GMT")
        return HttpDate.parse(timestampStr);
      } catch (e2) {
        // 如果都失败了，返回当前时间
        return DateTime.now();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'nickname': nickname,
      'action_type': actionType,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  String get actionTypeDisplay {
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

  String get detailsDisplay {
    switch (actionType) {
      case 'quiz_attempt':
        final quizTitle = details['quiz_title'] ?? '';
        final score = details['score'] ?? 0;
        final accuracy = details['accuracy'] ?? 0.0;
        return '测验: $quizTitle, 得分: $score, 准确率: ${accuracy.toStringAsFixed(1)}%';
      case 'learning_progress':
        final contentType = details['content_type'] ?? '';
        final contentId = details['content_id'] ?? '';
        final action = details['action'] ?? '';
        return '学习内容: $contentType ($contentId), 操作: $action';
      case 'post_created':
        final title = details['title'] ?? '';
        return '创建帖子: $title';
      case 'comment_created':
        final postTitle = details['post_title'] ?? '';
        return '评论帖子: $postTitle';
      default:
        return details.toString();
    }
  }
}

class LogsResponse {
  final List<ActivityLog> logs;
  final int page;
  final int perPage;

  LogsResponse({
    required this.logs,
    required this.page,
    required this.perPage,
  });

  factory LogsResponse.fromJson(Map<String, dynamic> json) {
    return LogsResponse(
      logs: (json['logs'] as List<dynamic>?)
          ?.map((log) => ActivityLog.fromJson(log))
          .toList() ?? [],
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
    );
  }
}

class LogStatistics {
  final int totalLogs;
  final int todayLogs;
  final List<ActionTypeStat> actionTypeStats;

  LogStatistics({
    required this.totalLogs,
    required this.todayLogs,
    required this.actionTypeStats,
  });

  factory LogStatistics.fromJson(Map<String, dynamic> json) {
    return LogStatistics(
      totalLogs: json['total_logs'] ?? 0,
      todayLogs: json['today_logs'] ?? 0,
      actionTypeStats: (json['action_type_stats'] as List<dynamic>?)
          ?.map((stat) => ActionTypeStat.fromJson(stat))
          .toList() ?? [],
    );
  }
}

class ActionTypeStat {
  final String actionType;
  final int count;
  final int uniqueUserCount;

  ActionTypeStat({
    required this.actionType,
    required this.count,
    required this.uniqueUserCount,
  });

  factory ActionTypeStat.fromJson(Map<String, dynamic> json) {
    return ActionTypeStat(
      actionType: json['action_type'] ?? '',
      count: json['count'] ?? 0,
      uniqueUserCount: json['unique_user_count'] ?? 0,
    );
  }

  String get actionTypeDisplay {
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

class RecentActivitiesResponse {
  final List<ActivityLog> recentActivities;
  final int limit;

  RecentActivitiesResponse({
    required this.recentActivities,
    required this.limit,
  });

  factory RecentActivitiesResponse.fromJson(Map<String, dynamic> json) {
    return RecentActivitiesResponse(
      recentActivities: (json['recent_activities'] as List<dynamic>?)
          ?.map((activity) => ActivityLog.fromJson(activity))
          .toList() ?? [],
      limit: json['limit'] ?? 10,
    );
  }
}