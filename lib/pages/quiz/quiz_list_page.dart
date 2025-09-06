import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../models/quiz.dart';
import '../../core/api_client.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  String? _type; // null 表示全部
  late Future<List<QuizItem>> _future;

  Future<List<QuizItem>> _fetch() async {
    final data = await ApiClient().get('/quiz/list', query: {
      if (_type != null) 'type': _type,
    });
    return (data as List).map((e) => QuizItem.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测验列表'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _type,
            onSelected: (v) => setState(() {
              _type = v;
              _future = _fetch();
            }),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: null, child: Text('全部')),
              const PopupMenuItem(value: 'vocab', child: Text('词汇')),
              const PopupMenuItem(value: 'grammar', child: Text('语法')),
              const PopupMenuItem(value: 'listening', child: Text('听力')),
            ],
            icon: const Icon(Icons.filter_list),
          )
        ],
      ),
      body: FutureBuilder<List<QuizItem>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('暂无测验'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final q = list[i];
              return ListTile(
                title: Text(q.title),
                subtitle: Text('类型: ${q.quizType}，总分: ${q.totalPoints}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/quiz_detail', arguments: q.quizId);
                },
              );
            },
          );
        },
      ),
    );
  }
}