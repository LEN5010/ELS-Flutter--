import 'package:flutter/material.dart';
import '../../core/admin_api.dart';
import '../../models/community.dart';

class AdminPendingPostsPage extends StatefulWidget {
  const AdminPendingPostsPage({super.key});
  @override
  State<AdminPendingPostsPage> createState() => _AdminPendingPostsPageState();
}

class _AdminPendingPostsPageState extends State<AdminPendingPostsPage> {
  late Future<List<PostItem>> _future;
  List<PostItem> _current = [];

  Future<List<PostItem>> _fetch() async {
    final list = await AdminApi.getPendingPosts();
    _current = List.from(list);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<void> _review(PostItem p, String status) async {
    try {
      await AdminApi.reviewPost(p.postId, status);
      setState(() {
        _current.removeWhere((e) => e.postId == p.postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已${"approved" == status ? "通过" : "驳回"}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostItem>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('加载失败：${snap.error}'));
        if (_current.isEmpty) return const Center(child: Text('暂无待审核帖子'));
        return ListView.separated(
          itemCount: _current.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = _current[i];
            return ListTile(
              title: Text(p.title),
              subtitle: Text('by ${p.nickname}\n${p.createdAt}\n${p.content}'),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18), label: const Text('通过'),
                    onPressed: () => _review(p, 'approved'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18), label: const Text('驳回'),
                    onPressed: () => _review(p, 'rejected'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}