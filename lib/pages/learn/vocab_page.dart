import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../models/vocab.dart';
import '../../models/paginated.dart';

class VocabPage extends StatefulWidget {
  const VocabPage({super.key});

  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage> {
  String _level = 'A1';
  int _page = 1;
  late Future<Paginated<VocabItem>> _future;

  Future<Paginated<VocabItem>> _fetch() async {
    final data = await ApiClient().get('/learning/vocab', query: {
      'level': _level,
      'page': _page,
      'per_page': defaultPageSize,
    });
    return Paginated.fromJson<VocabItem>(data, (e) => VocabItem.fromJson(e));
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
                    _page = 1;
                    _future = _fetch();
                  });
                },
              ),
              const Spacer(),
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
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Paginated<VocabItem>>(
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
              final paged = snap.data!;
              if (paged.data.isEmpty) {
                return const Center(child: Text('暂无词汇'));
              }
              return ListView.separated(
                itemCount: paged.data.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final w = paged.data[i];
                  return ListTile(
                    title: Text('${w.word}  (${w.level})'),
                    subtitle: Text('${w.meaning}\n例句: ${w.example}'),
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