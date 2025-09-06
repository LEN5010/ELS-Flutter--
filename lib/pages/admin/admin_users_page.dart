import 'package:flutter/material.dart';
import '../../core/admin_api.dart';
import '../../models/admin.dart';
import '../../models/paginated.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  int _page = 1;
  final int _perPage = 20;
  late Future<Paginated<AdminUser>> _future;

  Future<Paginated<AdminUser>> _fetch() => AdminApi.getUsers(page: _page, perPage: _perPage);

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  void _reload() {
    setState(() {
      _future = _fetch();
    });
  }

  Future<void> _changeRole(AdminUser u, String role) async {
    try {
      await AdminApi.updateUserRole(u.userId, role);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('角色更新成功')));
      _reload();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: _page > 1 ? () { setState(() { _page -= 1; _future = _fetch(); }); } : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('第 $_page 页'),
              IconButton(
                onPressed: () { setState(() { _page += 1; _future = _fetch(); }); },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Paginated<AdminUser>>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return Center(child: Text('加载失败：${snap.error}'));
              final paged = snap.data!;
              if (paged.data.isEmpty) return const Center(child: Text('暂无用户'));
              return ListView.separated(
                itemCount: paged.data.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final u = paged.data[i];
                  return ListTile(
                    title: Text('${u.nickname} (${u.email})'),
                    subtitle: Text('注册: ${u.createdAt}\n进度：V ${u.vocabLearned ?? 0} / G ${u.grammarLearned ?? 0} / L ${u.listeningDone ?? 0}'),
                    trailing: DropdownButton<String>(
                      value: u.role,
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('student')),
                        DropdownMenuItem(value: 'admin', child: Text('admin')),
                      ],
                      onChanged: (v) { if (v != null) _changeRole(u, v); },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}