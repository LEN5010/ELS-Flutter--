import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key});

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _category = 'general';
  bool _posting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _create(int userId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _posting = true);
    try {
      await ApiClient().post('/community/posts', body: {
        'user_id': userId,
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'category': _category,
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<SessionManager>().userId;
    return Scaffold(
      appBar: AppBar(title: const Text('发帖')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('general')),
                  DropdownMenuItem(value: 'question', child: Text('question')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'general'),
                decoration: const InputDecoration(labelText: '类别'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: '标题'),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtrl,
                minLines: 4,
                maxLines: 10,
                decoration: const InputDecoration(labelText: '内容', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入内容' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _posting || userId == null ? null : () => _create(userId),
                icon: const Icon(Icons.send),
                label: Text(_posting ? '发布中...' : '发布'),
              )
            ],
          ),
        ),
      ),
    );
  }
}