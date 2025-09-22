import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/session.dart';
import 'pages/splash_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/home/home_page.dart';
import 'pages/quiz/quiz_detail_page.dart';
import 'pages/community/post_detail_page.dart';
import 'pages/community/post_create_page.dart';
import 'pages/profile/edit_profile_page.dart';
import 'pages/logs/log_list_page.dart';
import 'pages/logs/log_statistics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionManager(),
      child: MaterialApp(
        title: 'English Learning System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashPage());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomePage());
            case '/quiz_detail':
              final quizId = settings.arguments as int;
              return MaterialPageRoute(builder: (_) => QuizDetailPage(quizId: quizId));
            case '/post_detail':
              final postId = settings.arguments as int;
              return MaterialPageRoute(builder: (_) => PostDetailPage(postId: postId));
            case '/post_create':
              return MaterialPageRoute(builder: (_) => const PostCreatePage());
            case '/edit_profile':
              return MaterialPageRoute(builder: (_) => const EditProfilePage());
            case '/logs':
              return MaterialPageRoute(builder: (_) => const LogListPage());
            case '/log_statistics':
              return MaterialPageRoute(builder: (_) => const LogStatisticsPage());
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Center(child: Text('404'))),
              );
          }
        },
      ),
    );
  }
}