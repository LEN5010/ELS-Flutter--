import 'dart:io';

String getBaseUrl() {
  // 本地联调：iOS 模拟器支持 localhost；Android 要用 10.0.2.2
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:5001/api';
}

const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const defaultPageSize = 20;