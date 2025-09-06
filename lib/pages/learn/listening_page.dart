import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../models/listening.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  String _level = 'A1';
  late Future<List<ListeningItem>> _future;

  Future<List<ListeningItem>> _fetch() async {
    final data = await ApiClient().get('/learning/listening', query: {'level': _level});
    return (data as List).map((e) => ListeningItem.fromJson(e)).toList();
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

  Future<void> _play(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法打开音频链接')));
      }
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
              const Text('等级：'),
              DropdownButton<String>(
                value: _level,
                items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _level = v;
                    _future = _fetch();
                  });
                },
              ),
              const Spacer(),
              IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ListeningItem>>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('加载失败：${snap.error}'),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _reload, child: const Text('重试'))
                    ],
                  ),
                );
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return const Center(child: Text('暂无听力材料'));
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = list[i];
                  return ListTile(
                    title: Text('${item.title} (${item.level})'),
                    subtitle: Text(item.transcript),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_fill),
                      onPressed: () => _play(item.audioUrl),
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