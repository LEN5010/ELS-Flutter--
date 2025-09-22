import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'storage.dart';

class SessionManager extends ChangeNotifier {
  bool isLoading = false;
  bool isLoggedIn = false;

  String? token;
  int? userId;
  String? email;
  String? nickname;
  String? role;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final s = await SecureStorage.readSession();
    token = s['token'];
    final uidStr = s['user_id'];
    userId = uidStr != null ? int.tryParse(uidStr) : null;
    email = s['email'];
    nickname = s['nickname'];
    role = s['role'];
    isLoggedIn = token != null && token!.isNotEmpty;
    isLoading = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient().post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      token = data['token'];
      userId = data['user_id'];
      this.email = data['email'];
      nickname = data['nickname'];
      role = data['role'];
      await SecureStorage.saveSession(
        token: token!,
        userId: userId!,
        email: this.email!,
        nickname: nickname ?? '',
        role: role ?? 'student',
      );
      isLoggedIn = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient().post('/auth/register', body: {
        'email': email,
        'password': password,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      });
      token = data['token'];
      userId = data['user_id'];
      this.email = data['email'];
      this.nickname = data['nickname'];
      role = 'student';
      await SecureStorage.saveSession(
        token: token!,
        userId: userId!,
        email: this.email!,
        nickname: this.nickname ?? '',
        role: role!,
      );
      isLoggedIn = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    await SecureStorage.clearSession();
    token = null;
    userId = null;
    email = null;
    nickname = null;
    role = null;
    isLoggedIn = false;
    isLoading = false;
    notifyListeners();
  }
}

class Session {
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final sessionData = await SecureStorage.readSession();
    if (sessionData['token'] == null) return null;

    return {
      'user_id': int.tryParse(sessionData['user_id'] ?? ''),
      'email': sessionData['email'],
      'nickname': sessionData['nickname'],
      'role': sessionData['role'],
    };
  }

  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?['role'] == 'admin';
  }

  static Future<int?> getUserId() async {
    final user = await getCurrentUser();
    return user?['user_id'];
  }
}