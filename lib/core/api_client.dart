import 'dart:async';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'storage.dart';

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException({required this.code, required this.message});
  @override
  String toString() => 'ApiException($code): $message';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    final options = BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (e, handler) {
        handler.next(e);
      },
    ));
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    dynamic body,
  }) async {
    try {
      final Response res = await _dio.request(
        path,
        queryParameters: query,
        data: body,
        options: Options(method: method),
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] ?? 500;
        final message = data['message']?.toString() ?? 'Unknown error';
        if (code == 200) {
          return data['data'];
        }
        throw ApiException(code: code, message: message);
      } else {
        throw ApiException(code: 500, message: 'Invalid response format');
      }
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data is Map<String, dynamic>
            ? (e.response?.data['message']?.toString() ?? e.message ?? 'Network error')
            : (e.message ?? 'Network error'),
      );
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path, {dynamic body, Map<String, dynamic>? query}) =>
      _request('POST', path, query: query, body: body);

  Future<dynamic> put(String path, {dynamic body, Map<String, dynamic>? query}) =>
      _request('PUT', path, query: query, body: body);

  Future<dynamic> delete(String path, {Map<String, dynamic>? query, dynamic body}) =>
      _request('DELETE', path, query: query, body: body);
}