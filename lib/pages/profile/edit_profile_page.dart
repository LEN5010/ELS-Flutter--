import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';
import '../../models/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nicknameCtrl = TextEditingController();
  String _gender = 'U';
  final _birthdayCtrl = TextEditingController();
  final _mypsCtrl = TextEditingController();
  bool _saving = false;
  late Future<User> _future;

  Future<User> _load(int userId) async {
    final data = await ApiClient().get('/user/profile/$userId');
    return User.fromJson(data);
  }

  @override
  void initState() {
    super.initState();
    final uid = context.read<SessionManager>().userId!;
    _future = _load(uid);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _birthdayCtrl.dispose();
    _mypsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(int userId) async {
    setState(() => _saving = true);
    try {
      await ApiClient().put('/user/profile/$userId', body: {
        'nickname': _nicknameCtrl.text.trim(),
        'gender': _gender,
        'birthday': _birthdayCtrl.text.trim(),
        'myps': _mypsCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<SessionManager>().userId!;
    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: FutureBuilder<User>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final user = snap.data!;
          _nicknameCtrl.text = user.nickname;
          _gender = _gender == 'U' ? user.gender : _gender;
          _birthdayCtrl.text = user.birthday ?? '';
          _mypsCtrl.text = user.myps ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(labelText: '昵称'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('男')),
                    DropdownMenuItem(value: 'F', child: Text('女')),
                    DropdownMenuItem(value: 'U', child: Text('未指定')),
                  ],
                  onChanged: (v) => setState(() => _gender = v ?? 'U'),
                  decoration: const InputDecoration(labelText: '性别'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _birthdayCtrl,
                  decoration: const InputDecoration(labelText: '生日（YYYY-MM-DD）'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mypsCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: '个人简介', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saving ? null : () => _save(uid),
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? '保存中...' : '保存'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}