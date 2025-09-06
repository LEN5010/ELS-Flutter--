import 'package:flutter/material.dart';
import 'vocab_page.dart';
import 'grammar_page.dart';
import 'listening_page.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('学习中心'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '词汇'),
              Tab(text: '语法'),
              Tab(text: '听力'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VocabPage(),
            GrammarPage(),
            ListeningPage(),
          ],
        ),
      ),
    );
  }
}