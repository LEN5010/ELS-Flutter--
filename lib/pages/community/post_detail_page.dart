import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';
import '../../models/community.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Future<(PostItem, List<CommentItem>)> _future;
  final _commentCtrl = TextEditingController();
  bool _posting = false;

  Future<(PostItem, List<CommentItem>)> _fetch() async {
    final data = await ApiClient().get('/community/posts/${widget.postId}');
    final post = PostItem.fromJson(data['post']);
    final comments = (data['comments'] as List).map((e) => CommentItem.fromJson(e)).toList();
    return (post, comments);
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment(int userId) async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    try {
      await ApiClient().post('/community/posts/${widget.postId}/comments', body: {
        'user_id': userId,
        'content': _commentCtrl.text.trim(),
      });
      _commentCtrl.clear();
      setState(() {
        _future = _fetch();
      });
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
      appBar: AppBar(title: const Text('帖子详情')),
      body: FutureBuilder<(PostItem, List<CommentItem>)>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final (post, comments) = snap.data!;
          return Column(
            children: [
              ListTile(
                title: Text(post.title),
                subtitle: Text('by ${post.nickname} • ${post.category} • ${post.status}\n${post.createdAt}'),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(post.content),
              ),
              const Divider(height: 1),
              Expanded(
                child: comments.isEmpty
                    ? const Center(child: Text('暂无评论'))
                    : ListView.separated(
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = comments[i];
                          return ListTile(
                            title: Text(c.nickname),
                            subtitle: Text('${c.content}\n${c.createdAt}'),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: const InputDecoration(
                            hintText: '写下你的评论...',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _posting || userId == null ? null : () => _submitComment(userId),
                        child: _posting ? const Text('提交中...') : const Text('发送'),
                      )
                    ],
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