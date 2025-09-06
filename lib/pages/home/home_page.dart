import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/session.dart';
import '../learn/learn_page.dart';
import '../quiz/quiz_list_page.dart';
import '../community/post_list_page.dart';
import '../profile/profile_page.dart';
import '../admin/admin_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<SessionManager>().role ?? 'student';
    final isAdmin = role == 'admin';

    final pages = <Widget>[
      const LearnPage(),
      const QuizListPage(),
      const PostListPage(),
      const ProfilePage(),
      if (isAdmin) const AdminPanelPage(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: '学习'),
      const NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: '测验'),
      const NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: '社区'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
      if (isAdmin) const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: '管理'),
    ];

    final idx = _idx.clamp(0, pages.length - 1);
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        destinations: destinations,
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}