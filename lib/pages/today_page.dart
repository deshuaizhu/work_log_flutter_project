import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_log_entry.dart';
import '../services/storage_service.dart';
import '../widgets/work_log_item.dart';
import '../widgets/time_range_picker.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final StorageService _storageService = StorageService();
  List<WorkLogEntry> _entries = [];
  DateTime _selectedDate = DateTime.now();

  DateTime get _today => DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = _storageService.getEntriesByDate(_selectedDate);
    setState(() {
      _entries = entries;
    });
  }

  bool get _isToday {
    final today = _today;
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF136dec),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEntries();
    }
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = _today;
    });
    _loadEntries();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  // 获取默认的开始和结束时间
  (TimeOfDay, TimeOfDay) _getDefaultTimes() {
    if (_entries.isEmpty) {
      // 如果没有记录，默认开始时间为09:00，结束时间为09:30
      return (
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 9, minute: 30)
      );
    }

    // 找到最后一条记录（按结束时间排序）
    final sortedEntries = List<WorkLogEntry>.from(_entries)
      ..sort((a, b) {
        final aMinutes = a.endTime.hour * 60 + a.endTime.minute;
        final bMinutes = b.endTime.hour * 60 + b.endTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    final lastEntry = sortedEntries.last;
    final lastEndTime = lastEntry.endTime;

    // 开始时间 = 最后一条记录的结束时间
    // 结束时间 = 开始时间 + 30分钟
    final startMinutes = lastEndTime.hour * 60 + lastEndTime.minute;
    final endMinutes = startMinutes + 30;

    final startHour = (startMinutes ~/ 60) % 24;
    final startMinute = startMinutes % 60;
    final endHour = (endMinutes ~/ 60) % 24;
    final endMinute = endMinutes % 60;

    return (
      TimeOfDay(hour: startHour, minute: startMinute),
      TimeOfDay(hour: endHour, minute: endMinute),
    );
  }

  void _showAddDialog() {
    final (defaultStartTime, defaultEndTime) = _getDefaultTimes();
    TimeOfDay startTime = defaultStartTime;
    TimeOfDay endTime = defaultEndTime;
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('添加工作记录'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间选择器
                  TimeRangePicker(
                    initialStartTime: startTime,
                    initialEndTime: endTime,
                    onTimeSelected: (start, end) {
                      setDialogState(() {
                        startTime = start;
                        endTime = end;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 内容输入框
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '请输入工作内容',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('工作内容不能为空'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  final entry = WorkLogEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: _selectedDate,
                    startTime: startTime,
                    endTime: endTime,
                    content: contentController.text.trim(),
                  );

                  _storageService.addEntry(entry).then((_) {
                    Navigator.of(context).pop();
                    _loadEntries();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136dec),
                  foregroundColor: Colors.white,
                ),
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleUpdate(WorkLogEntry entry) async {
    await _storageService.updateEntry(entry);
    _loadEntries();
  }

  Future<void> _handleDelete(String id) async {
    await _storageService.deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF101822) : const Color(0xFFf6f7f8),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: _selectDate,
                        tooltip: '选择日期',
                      ),
                      if (!_isToday) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: '重置到今日',
                          child: IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _resetToToday,
                            tooltip: '重置到今日',
                          ),
                        ),
                      ],
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('添加记录'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF136dec),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 工作记录列表
              if (_entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isToday
                              ? '今天还没有工作记录'
                              : '${_formatDate(_selectedDate)}还没有工作记录',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击"添加记录"按钮开始记录您的工作',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._entries.map((entry) => WorkLogItem(
                      entry: entry,
                      onDelete: () => _handleDelete(entry.id),
                      onUpdate: _handleUpdate,
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
