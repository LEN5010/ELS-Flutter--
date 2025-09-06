import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _kToken = 'token';
  static const _kUserId = 'user_id';
  static const _kEmail = 'email';
  static const _kNickname = 'nickname';
  static const _kRole = 'role';

  static Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
    required String nickname,
    required String role,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserId, value: userId.toString());
    await _storage.write(key: _kEmail, value: email);
    await _storage.write(key: _kNickname, value: nickname);
    await _storage.write(key: _kRole, value: role);
  }

  static Future<Map<String, String?>> readSession() async {
    final token = await _storage.read(key: _kToken);
    final userId = await _storage.read(key: _kUserId);
    final email = await _storage.read(key: _kEmail);
    final nickname = await _storage.read(key: _kNickname);
    final role = await _storage.read(key: _kRole);
    return {
      'token': token,
      'user_id': userId,
      'email': email,
      'nickname': nickname,
      'role': role,
    };
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  static Future<String?> getToken() => _storage.read(key: _kToken);
  static Future<String?> getUserId() => _storage.read(key: _kUserId);
}