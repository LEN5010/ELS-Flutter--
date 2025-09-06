import 'package:flutter/material.dart';
import '../../core/admin_api.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../models/vocab.dart';
import '../../models/paginated.dart';

class AdminResourcesPage extends StatefulWidget {
  const AdminResourcesPage({super.key});
  @override
  State<AdminResourcesPage> createState() => _AdminResourcesPageState();
}

class _AdminResourcesPageState extends State<AdminResourcesPage> {
  // 添加词汇表单
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  String _levelAdd = 'A1';
  bool _adding = false;

  // 查询/编辑词汇
  String _levelList = 'A1';
  int _page = 1;
  late Future<Paginated<VocabItem>> _future;

  Future<Paginated<VocabItem>> _fetch() async {
    final data = await ApiClient().get('/learning/vocab', query: {'level': _levelList, 'page': _page, 'per_page': defaultPageSize});
    return Paginated.fromJson<VocabItem>(data, (e) => VocabItem.fromJson(e));
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addVocab() async {
    if (_wordCtrl.text.trim().isEmpty || _meaningCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写单词和释义')));
      return;
    }
    setState(() => _adding = true);
    try {
      await AdminApi.addVocab(
        word: _wordCtrl.text.trim(),
        meaning: _meaningCtrl.text.trim(),
        example: _exampleCtrl.text.trim().isEmpty ? null : _exampleCtrl.text.trim(),
        level: _levelAdd,
      );
      _wordCtrl.clear(); _meaningCtrl.clear(); _exampleCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('添加成功')));
      setState(() { _future = _fetch(); });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败：$e')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _editVocab(VocabItem v) async {
    final wordCtrl = TextEditingController(text: v.word);
    final meaningCtrl = TextEditingController(text: v.meaning);
    final exampleCtrl = TextEditingController(text: v.example);
    String level = v.level;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('编辑词汇 #${v.wordId}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: wordCtrl, decoration: const InputDecoration(labelText: '单词')),
              TextField(controller: meaningCtrl, decoration: const InputDecoration(labelText: '释义')),
              TextField(controller: exampleCtrl, decoration: const InputDecoration(labelText: '例句')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: level,
                items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => level = v ?? level,
                decoration: const InputDecoration(labelText: '等级'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await AdminApi.updateVocab(v.wordId,
          word: wordCtrl.text.trim(),
          meaning: meaningCtrl.text.trim(),
          example: exampleCtrl.text.trim(),
          level: level);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
      setState(() { _future = _fetch(); });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失败：$e')));
    } finally {
      wordCtrl.dispose(); meaningCtrl.dispose(); exampleCtrl.dispose();
    }
  }

  Future<void> _deleteVocab(int wordId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定删除词汇 #$wordId 吗？此操作不可恢复'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.deleteVocab(wordId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('删除成功')));
      setState(() { _future = _fetch(); });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('添加词汇', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _wordCtrl, decoration: const InputDecoration(labelText: '单词'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _meaningCtrl, decoration: const InputDecoration(labelText: '释义'))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: _exampleCtrl, decoration: const InputDecoration(labelText: '例句')),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('等级：'),
            DropdownButton<String>(
              value: _levelAdd,
              items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _levelAdd = v ?? 'A1'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _adding ? null : _addVocab,
              icon: const Icon(Icons.add),
              label: Text(_adding ? '添加中...' : '添加'),
            ),
          ],
        ),
        const Divider(height: 24),
        Row(
          children: [
            const Text('浏览词汇：等级'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _levelList,
              items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() { _levelList = v; _page = 1; _future = _fetch(); });
              },
            ),
            const Spacer(),
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
        const SizedBox(height: 8),
        FutureBuilder<Paginated<VocabItem>>(
          future: _future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Text('加载失败：${snap.error}');
            final page = snap.data!;
            if (page.data.isEmpty) return const Text('暂无数据');
            return Column(
              children: page.data.map((v) => Card(
                child: ListTile(
                  title: Text('${v.word} (${v.level})'),
                  subtitle: Text(v.meaning),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editVocab(v)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteVocab(v.wordId)),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        )
      ],
    );
  }
}