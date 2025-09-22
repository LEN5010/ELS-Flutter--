import 'package:flutter/material.dart';
import '../../services/log_service.dart';
import '../../models/log.dart';
import '../../core/session.dart';

class LogListPage extends StatefulWidget {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends State<LogListPage> {
  int _page = 1;
  final int _perPage = 20;
  bool _isLoading = false;
  final List<ActivityLog> _logs = [];
  final ScrollController _scrollController = ScrollController();
  String? _selectedActionType;
  int? _selectedUserId;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLogs();
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
      _page = 1;
    });

    try {
      LogsResponse response;
      final user = await Session.getCurrentUser();
      final isAdmin = user?['role'] == 'admin';

      if (_startDate != null && _endDate != null && isAdmin) {
        response = await LogService.getLogsByDateRange(
          startDate: _startDate!,
          endDate: _endDate!,
          userId: _selectedUserId,
          page: _page,
          perPage: _perPage,
        );
      } else if (_selectedActionType != null && isAdmin) {
        response = await LogService.getLogsByAction(
          _selectedActionType!,
          page: _page,
          perPage: _perPage,
        );
      } else if (_selectedUserId != null && isAdmin) {
        response = await LogService.getUserLogs(
          _selectedUserId!,
          page: _page,
          perPage: _perPage,
        );
      } else {
        response = await LogService.getMyLogs(
          page: _page,
          perPage: _perPage,
        );
      }

      setState(() {
        _logs.addAll(response.logs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreLogs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _page++;
    });

    try {
      LogsResponse response;
      final user = await Session.getCurrentUser();
      final isAdmin = user?['role'] == 'admin';

      if (_startDate != null && _endDate != null && isAdmin) {
        response = await LogService.getLogsByDateRange(
          startDate: _startDate!,
          endDate: _endDate!,
          userId: _selectedUserId,
          page: _page,
          perPage: _perPage,
        );
      } else if (_selectedActionType != null && isAdmin) {
        response = await LogService.getLogsByAction(
          _selectedActionType!,
          page: _page,
          perPage: _perPage,
        );
      } else if (_selectedUserId != null && isAdmin) {
        response = await LogService.getUserLogs(
          _selectedUserId!,
          page: _page,
          perPage: _perPage,
        );
      } else {
        response = await LogService.getMyLogs(
          page: _page,
          perPage: _perPage,
        );
      }

      setState(() {
        _logs.addAll(response.logs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _page--; // 回退页码
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final user = await Session.getCurrentUser();
    final isAdmin = user?['role'] == 'admin';

    if (!isAdmin) return;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选日志'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedActionType,
                  decoration: const InputDecoration(labelText: '操作类型'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('全部')),
                    ...LogService.getActionTypes().map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(LogService.getActionTypeDisplay(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedActionType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: '用户ID（可选）'),
                  keyboardType: TextInputType.number,
                  initialValue: _selectedUserId?.toString(),
                  onChanged: (value) {
                    _selectedUserId = int.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: '开始日期'),
                        readOnly: true,
                        controller: TextEditingController(text: _startDate),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _startDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: '结束日期'),
                        readOnly: true,
                        controller: TextEditingController(text: _endDate),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _endDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedActionType = null;
                _selectedUserId = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
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

  Widget _buildLogItem(ActivityLog log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionTypeColor(log.actionType),
          child: Icon(
            _getActionTypeIcon(log.actionType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          log.actionTypeDisplay,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用户: ${log.nickname} (ID: ${log.userId})'),
            if (log.details.isNotEmpty)
              Text(
                log.detailsDisplay,
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              _formatTimestamp(log.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动日志'),
        actions: [
          FutureBuilder(
            future: Session.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?['role'] == 'admin') {
                return Row(
                  children: [
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list),
                      tooltip: '筛选',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/log_statistics');
                      },
                      icon: const Icon(Icons.analytics),
                      tooltip: '统计',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: _logs.isEmpty && !_isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '暂无日志记录',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _logs.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _logs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _buildLogItem(_logs[index]);
                },
              ),
      ),
    );
  }
}