import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_users_page.dart';
import 'admin_pending_posts_page.dart';
import 'admin_resources_page.dart';
import 'admin_quiz_page.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('管理后台'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '仪表盘'),
              Tab(text: '用户'),
              Tab(text: '待审核'),
              Tab(text: '资源'),
              Tab(text: '测验'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminDashboardPage(),
            AdminUsersPage(),
            AdminPendingPostsPage(),
            AdminResourcesPage(),
            AdminQuizPage(),
          ],
        ),
      ),
    );
  }
}