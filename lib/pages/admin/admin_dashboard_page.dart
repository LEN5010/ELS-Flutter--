import 'package:flutter/material.dart';
import '../../core/admin_api.dart';
import '../../models/admin.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<(AdminStatistics, List<QuizPerformance>, UserProgressStats)> _future;

  Future<(AdminStatistics, List<QuizPerformance>, UserProgressStats)> _fetch() async {
    final stats = await AdminApi.getStatistics();
    final perf = await AdminApi.getQuizPerformance();
    final ups  = await AdminApi.getUserProgressStats();
    return (stats, perf, ups);
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(AdminStatistics, List<QuizPerformance>, UserProgressStats)>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('加载失败：${snap.error}'));
        }
        final (s, perf, ups) = snap.data!;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _fetch()),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Wrap(
                spacing: 12, runSpacing: 12,
                children: [
                  _tile('用户总数', '${s.users.totalUsers}'),
                  _tile('管理员', '${s.users.adminCount}'),
                  _tile('学生', '${s.users.studentCount}'),
                  _tile('今日新增', '${s.todayUsers}'),
                  _tile('词汇', '${s.vocabCount}'),
                  _tile('语法', '${s.grammarCount}'),
                  _tile('听力', '${s.listeningCount}'),
                  _tile('测验', '${s.quizCount}'),
                  _tile('测验提交', '${s.quizAttempts}'),
                  _tile('帖子总数', '${s.posts.totalPosts}'),
                  _tile('待审核帖子', '${s.posts.pendingPosts}'),
                  _tile('评论数', '${s.commentCount}'),
                ],
              ),
              const SizedBox(height: 12),
              const Text('测验表现（按参与度）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (perf.isEmpty) const Text('暂无数据')
              else ...perf.map((p) => Card(
                child: ListTile(
                  title: Text('${p.title} (${p.quizType})'),
                  subtitle: Text('参与: ${p.attemptCount}  平均分: ${p.avgScore?.toStringAsFixed(1) ?? '-'}  平均准确率: ${p.avgAccuracy.toStringAsFixed(1)}%'),
                  trailing: Text('最高: ${p.maxScore ?? '-'} 最低: ${p.minScore ?? '-'}'),
                ),
              )),
              const SizedBox(height: 12),
              const Text('学习进度统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Card(
                child: ListTile(
                  title: const Text('平均/最高统计'),
                  subtitle: Text('词汇 平均${ups.avgVocab.toStringAsFixed(1)} 最高${ups.maxVocab}\n'
                      '语法 平均${ups.avgGrammar.toStringAsFixed(1)} 最高${ups.maxGrammar}\n'
                      '听力 平均${ups.avgListening.toStringAsFixed(1)} 最高${ups.maxListening}\n'
                      '7日活跃用户: ${ups.activeUsers7days}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(String k, String v) => SizedBox(
    width: 160,
    child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(k), const SizedBox(height: 4), Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
    ))),
  );
}