import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../models/community.dart';
import '../../models/paginated.dart';
import '../../core/constants.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  String _category = 'general';
  String _status = 'approved';
  int _page = 1;
  late Future<Paginated<PostItem>> _future;

  Future<Paginated<PostItem>> _fetch() async {
    final data = await ApiClient().get('/community/posts', query: {
      'category': _category,
      'status': _status,
      'page': _page,
      'per_page': defaultPageSize,
    });
    return Paginated.fromJson<PostItem>(data, (e) => PostItem.fromJson(e));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/post_create');
              _reload();
            },
            icon: const Icon(Icons.add),
            tooltip: '发帖',
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.3),
            child: Row(
              children: [
                const Text('类别：'),
                DropdownButton<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('general')),
                    DropdownMenuItem(
                        value: 'question', child: Text('question')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _category = v;
                      _page = 1;
                      _future = _fetch();
                    });
                  },
                ),
                const Text('状态：'),
                DropdownButton<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(
                        value: 'approved', child: Text('approved')),
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                    DropdownMenuItem(
                        value: 'rejected', child: Text('rejected')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _status = v;
                      _page = 1;
                      _future = _fetch();
                    });
                  },
                ),
                IconButton(
                  onPressed: _page > 1
                      ? () {
                          setState(() {
                            _page -= 1;
                            _future = _fetch();
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('第 $_page 页'),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _page += 1;
                      _future = _fetch();
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Paginated<PostItem>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('加载失败：${snap.error}'));
                }
                final paged = snap.data!;
                if (paged.data.isEmpty)
                  return const Center(child: Text('暂无帖子'));

                return ListView.separated(
                  itemCount: paged.data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = paged.data[i];
                    return ListTile(
                      title: Text(p.title),
                      subtitle: Text(
                          'by ${p.nickname} • ${p.category} • ${p.status}\n${p.createdAt}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.comment, size: 16),
                          const SizedBox(width: 4),
                          Text('${p.commentCount ?? 0}')
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(context, '/post_detail',
                          arguments: p.postId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
