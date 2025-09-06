import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';
import '../../models/quiz.dart';

class QuizDetailPage extends StatefulWidget {
  final int quizId;
  const QuizDetailPage({super.key, required this.quizId});

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  late Future<(QuizMeta, List<Question>)> _future;
  final Map<int, String> _answers = {};
  bool _submitting = false;

  Future<(QuizMeta, List<Question>)> _fetch() async {
    final data = await ApiClient().get('/quiz/${widget.quizId}/questions');
    final quiz = QuizMeta.fromJson(data['quiz']);
    final questions = (data['questions'] as List).map((e) => Question.fromJson(e)).toList();
    return (quiz, questions);
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<void> _submit(int userId) async {
    setState(() => _submitting = true);
    try {
      final resultData = await ApiClient().post('/quiz/${widget.quizId}/submit', body: {
        'user_id': userId,
        'answers': _answers.map((k, v) => MapEntry(k.toString(), v)),
      });
      final result = QuizResult.fromJson(resultData);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('测验结果'),
            content: Text('得分: ${result.score}\n正确数: ${result.correctCount}/${result.totalCount}\n准确率: ${result.accuracy}%\n等级: ${result.level}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))
            ],
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<SessionManager>().userId;
    return Scaffold(
      appBar: AppBar(title: const Text('测验详情')),
      body: FutureBuilder<(QuizMeta, List<Question>)>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final (quiz, questions) = snap.data!;
          return Column(
            children: [
              ListTile(
                title: Text(quiz.title),
                subtitle: Text('类型: ${quiz.quizType}，总分: ${quiz.totalPoints}'),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (_, i) {
                    final q = questions[i];
                    final selected = _answers[q.questionId];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Q${i + 1}. ${q.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            RadioListTile<String>(
                              value: 'A',
                              groupValue: selected,
                              onChanged: (v) => setState(() => _answers[q.questionId] = v!),
                              title: Text('A. ${q.optionA}'),
                            ),
                            RadioListTile<String>(
                              value: 'B',
                              groupValue: selected,
                              onChanged: (v) => setState(() => _answers[q.questionId] = v!),
                              title: Text('B. ${q.optionB}'),
                            ),
                            RadioListTile<String>(
                              value: 'C',
                              groupValue: selected,
                              onChanged: (v) => setState(() => _answers[q.questionId] = v!),
                              title: Text('C. ${q.optionC}'),
                            ),
                            RadioListTile<String>(
                              value: 'D',
                              groupValue: selected,
                              onChanged: (v) => setState(() => _answers[q.questionId] = v!),
                              title: Text('D. ${q.optionD}'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: _submitting || userId == null ? null : () => _submit(userId),
                    icon: const Icon(Icons.send),
                    label: Text(_submitting ? '提交中...' : '提交答案'),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}