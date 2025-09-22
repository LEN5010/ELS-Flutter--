import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';
import '../../models/user.dart';
import '../../models/progress.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<(User, Progress?, List<QuizHistoryItem>)> _future;

  Future<(User, Progress?, List<QuizHistoryItem>)> _fetch(int userId) async {
    final userData = await ApiClient().get('/user/profile/$userId');
    final user = User.fromJson(userData);
    final progData = await ApiClient().get('/user/progress/$userId');
    final progress = progData['progress'] != null ? Progress.fromJson(progData['progress']) : null;
    final history = (progData['quiz_history'] as List?)?.map((e) => QuizHistoryItem.fromJson(e)).toList() ?? [];
    return (user, progress, history);
  }

  @override
  void initState() {
    super.initState();
    final uid = context.read<SessionManager>().userId;
    _future = _fetch(uid!);
  }

  void _reload() {
    final uid = context.read<SessionManager>().userId!;
    setState(() {
      _future = _fetch(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit_profile').then((_) => _reload()),
            icon: const Icon(Icons.edit),
            tooltip: '编辑资料',
          ),
          IconButton(
            onPressed: session.isLoading
                ? null
                : () async {
                    await session.logout();
                    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          ),
        ],
      ),
      body: FutureBuilder<(User, Progress?, List<QuizHistoryItem>)>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('加载失败：${snap.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _reload, child: const Text('重试'))
                ],
              ),
            );
          }
          final (user, progress, history) = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              children: [
                ListTile(
                  title: Text(user.nickname),
                  subtitle: Text('${user.email} • 角色: ${user.role}'),
                ),
                ListTile(
                  title: const Text('性别'),
                  subtitle: Text(user.gender),
                ),
                ListTile(
                  title: const Text('生日'),
                  subtitle: Text(user.birthday ?? '-'),
                ),
                ListTile(
                  title: const Text('个人简介'),
                  subtitle: Text(user.myps ?? ''),
                ),
                const Divider(height: 1),
                const Divider(height: 1),
                const ListTile(title: Text('测验历史')),
                if (history.isEmpty)
                  const ListTile(title: Text('暂无测验记录'))
                else
                  ...history.map((h) => ListTile(
                        title: Text('${h.title} (${h.quizType})'),
                        subtitle: Text(h.takenAt),
                        trailing: Text('${h.score} (${h.correctCnt}/${h.totalCnt})'),
                      )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}