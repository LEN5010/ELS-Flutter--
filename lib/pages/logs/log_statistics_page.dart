import 'package:flutter/material.dart';
import '../../services/log_service.dart';
import '../../models/log.dart';

class LogStatisticsPage extends StatefulWidget {
  const LogStatisticsPage({super.key});

  @override
  State<LogStatisticsPage> createState() => _LogStatisticsPageState();
}

class _LogStatisticsPageState extends State<LogStatisticsPage> {
  late Future<LogStatistics> _future;
  late Future<RecentActivitiesResponse> _recentActivitiesFuture;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = LogService.getLogStatistics(
        startDate: _startDate,
        endDate: _endDate,
      );
      _recentActivitiesFuture = LogService.getRecentActivities(limit: 20);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(
              start: DateTime.parse(_startDate!),
              end: DateTime.parse(_endDate!),
            )
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
        _endDate = '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
      });
      _loadData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadData();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTypeChart(List<ActionTypeStat> stats) {
    if (stats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无数据'),
          ),
        ),
      );
    }

    final totalCount = stats.fold<int>(0, (sum, stat) => sum + stat.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作类型分布',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              final colors = [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.red,
                Colors.teal,
                Colors.indigo,
              ];
              final color = colors[index % colors.length];
              final percentage = (stat.count / totalCount * 100).toStringAsFixed(1);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            stat.actionTypeDisplay,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${stat.count} 次 ($percentage%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: stat.count / totalCount,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(List<ActivityLog> activities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近活动',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(child: Text('暂无最近活动'))
            else
              ...activities.take(10).map((activity) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActionTypeColor(activity.actionType),
                  radius: 16,
                  child: Icon(
                    _getActionTypeIcon(activity.actionType),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  activity.actionTypeDisplay,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${activity.nickname} - ${_formatTimestamp(activity.timestamp)}',
                  style: const TextStyle(fontSize: 12),
                ),
                dense: true,
              )),
          ],
        ),
      ),
    );
  }

  Color _getActionTypeColor(String actionType) {
    switch (actionType) {
      case 'user_login':
        return Colors.green;
      case 'user_logout':
        return Colors.orange;
      case 'quiz_attempt':
        return Colors.blue;
      case 'learning_progress':
        return Colors.purple;
      case 'post_created':
        return Colors.indigo;
      case 'comment_created':
        return Colors.teal;
      case 'admin_action':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionTypeIcon(String actionType) {
    switch (actionType) {
      case 'user_login':
        return Icons.login;
      case 'user_logout':
        return Icons.logout;
      case 'quiz_attempt':
        return Icons.quiz;
      case 'learning_progress':
        return Icons.school;
      case 'post_created':
        return Icons.post_add;
      case 'comment_created':
        return Icons.comment;
      case 'admin_action':
        return Icons.admin_panel_settings;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志统计'),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: '选择日期范围',
          ),
          if (_startDate != null || _endDate != null)
            IconButton(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.clear),
              tooltip: '清除日期筛选',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_startDate != null && _endDate != null)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('筛选日期: $_startDate 至 $_endDate'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FutureBuilder<LogStatistics>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text('加载失败: ${snapshot.error}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final statistics = snapshot.data!;

                  return Column(
                    children: [
                      // 基础统计卡片
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildStatCard(
                            title: '总日志数',
                            value: statistics.totalLogs.toString(),
                            icon: Icons.description,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            title: '今日日志',
                            value: statistics.todayLogs.toString(),
                            icon: Icons.today,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // 操作类型分布图
                      _buildActionTypeChart(statistics.actionTypeStats),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // 最近活动
              FutureBuilder<RecentActivitiesResponse>(
                future: _recentActivitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('加载最近活动失败: ${snapshot.error}'),
                      ),
                    );
                  }

                  return _buildRecentActivities(snapshot.data?.recentActivities ?? []);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}