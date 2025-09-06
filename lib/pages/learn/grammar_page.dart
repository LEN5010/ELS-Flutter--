import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../models/grammar.dart';

class GrammarPage extends StatefulWidget {
  const GrammarPage({super.key});

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  String _level = 'A1';
  late Future<List<GrammarItem>> _future;

  Future<List<GrammarItem>> _fetch() async {
    final data = await ApiClient().get('/learning/grammar', query: {'level': _level});
    return (data as List).map((e) => GrammarItem.fromJson(e)).toList();
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
          child: FutureBuilder<List<GrammarItem>>(
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
                return const Center(child: Text('暂无语法教程'));
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final g = list[i];
                  return ExpansionTile(
                    title: Text('${g.title}  (${g.level})'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(g.content),
                      ),
                    ],
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