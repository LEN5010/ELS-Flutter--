import 'package:flutter/material.dart';
import '../../core/admin_api.dart';

class AdminQuizPage extends StatefulWidget {
  const AdminQuizPage({super.key});
  @override
  State<AdminQuizPage> createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  // 创建测验
  String _quizType = 'vocab';
  final _titleCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '100');
  int? _createdQuizId;
  bool _creating = false;

  // 添加题目
  final _quizIdCtrl = TextEditingController();
  final _qCtrl = TextEditingController();
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _dCtrl = TextEditingController();
  String _correct = 'A';
  final _scoreCtrl = TextEditingController(text: '20');
  bool _adding = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _pointsCtrl.dispose();
    _quizIdCtrl.dispose();
    _qCtrl.dispose();
    _aCtrl.dispose();
    _bCtrl.dispose();
    _cCtrl.dispose();
    _dCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _creating = true);
    try {
      final id = await AdminApi.createQuiz(
        quizType: _quizType,
        title: _titleCtrl.text.trim(),
        totalPoints: int.tryParse(_pointsCtrl.text.trim()) ?? 100,
      );
      setState(() {
        _createdQuizId = id;
        _quizIdCtrl.text = id.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建成功，ID=$id')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建失败：$e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _addQuestion() async {
    final qid = int.tryParse(_quizIdCtrl.text.trim().isEmpty && _createdQuizId != null
        ? _createdQuizId.toString()
        : _quizIdCtrl.text.trim());
    if (qid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写测验ID')));
      return;
    }
    if (_qCtrl.text.trim().isEmpty || _aCtrl.text.trim().isEmpty || _bCtrl.text.trim().isEmpty
        || _cCtrl.text.trim().isEmpty || _dCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完整填写题干与四个选项')));
      return;
    }
    setState(() => _adding = true);
    try {
      final qidNew = await AdminApi.addQuizQuestion(
        quizId: qid,
        question: _qCtrl.text.trim(),
        a: _aCtrl.text.trim(), b: _bCtrl.text.trim(), c: _cCtrl.text.trim(), d: _dCtrl.text.trim(),
        correct: _correct, score: int.tryParse(_scoreCtrl.text.trim()) ?? 20,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加题目 #$qidNew')));
      _qCtrl.clear(); _aCtrl.clear(); _bCtrl.clear(); _cCtrl.clear(); _dCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败：$e')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('创建测验', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Text('类型：'),
            DropdownButton<String>(
              value: _quizType,
              items: const [
                DropdownMenuItem(value: 'vocab', child: Text('vocab')),
                DropdownMenuItem(value: 'grammar', child: Text('grammar')),
                DropdownMenuItem(value: 'listening', child: Text('listening')),
              ],
              onChanged: (v) => setState(() => _quizType = v ?? 'vocab'),
            ),
          ],
        ),
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: '标题')),
        TextField(controller: _pointsCtrl, decoration: const InputDecoration(labelText: '总分'), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: _creating ? null : _createQuiz, icon: const Icon(Icons.add), label: Text(_creating ? '创建中...' : '创建')),
        if (_createdQuizId != null) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('已创建测验 ID: $_createdQuizId'),
        ),
        const Divider(height: 24),
        const Text('添加题目', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(controller: _quizIdCtrl, decoration: const InputDecoration(labelText: '测验ID（留空则使用上面创建的ID）'), keyboardType: TextInputType.number),
        TextField(controller: _qCtrl, decoration: const InputDecoration(labelText: '题干')),
        TextField(controller: _aCtrl, decoration: const InputDecoration(labelText: '选项A')),
        TextField(controller: _bCtrl, decoration: const InputDecoration(labelText: '选项B')),
        TextField(controller: _cCtrl, decoration: const InputDecoration(labelText: '选项C')),
        TextField(controller: _dCtrl, decoration: const InputDecoration(labelText: '选项D')),
        Row(
          children: [
            const Text('正确：'),
            DropdownButton<String>(
              value: _correct,
              items: const [
                DropdownMenuItem(value: 'A', child: Text('A')),
                DropdownMenuItem(value: 'B', child: Text('B')),
                DropdownMenuItem(value: 'C', child: Text('C')),
                DropdownMenuItem(value: 'D', child: Text('D')),
              ],
              onChanged: (v) => setState(() => _correct = v ?? 'A'),
            ),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _scoreCtrl, decoration: const InputDecoration(labelText: '分值'), keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: _adding ? null : _addQuestion, icon: const Icon(Icons.playlist_add), label: Text(_adding ? '添加中...' : '添加题目')),
      ],
    );
  }
}