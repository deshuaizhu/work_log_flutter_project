import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_log_entry.dart';
import '../services/storage_service.dart';
import '../widgets/time_range_picker.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final StorageService _storageService = StorageService();
  Map<DateTime, List<WorkLogEntry>> _groupedEntries = {};
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final grouped = _storageService.getEntriesGroupedByDate(_startDate, _endDate);
    setState(() {
      _groupedEntries = grouped;
    });
  }

  String _formatDate(DateTime date) {
    final weekday = DateFormat('EEEE', 'zh_CN').format(date);
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date) + ' $weekday';
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      });
      _loadEntries();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
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
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _loadEntries();
    }
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
    final sortedDates = _groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));
    
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
                  const Text(
                    '历史记录',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // 日期范围选择器
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? const Color(0xFF19212b) : Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _selectStartDate,
                          child: Text(
                            _formatDateShort(_startDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Text(' - '),
                        InkWell(
                          onTap: _selectEndDate,
                          child: Text(
                            _formatDateShort(_endDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 工作记录列表
              if (_groupedEntries.isEmpty)
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(80),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off,
                              size: 32,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '未找到记录',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '所选时段内没有工作日志条目。',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: sortedDates.map((date) {
                      final entries = _groupedEntries[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 日期标题
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                _formatDate(date),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                          
                          // 该日期的工作记录
                          ...entries.map((entry) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 图标
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.schedule,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // 内容和时间
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.timeRange,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.content,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // 操作按钮
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {
                                            _showEditDialog(entry);
                                          },
                                          tooltip: '编辑',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          color: Colors.red[400],
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('确认删除'),
                                                content: const Text('确定要删除这条工作记录吗？'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('取消'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      _handleDelete(entry.id);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                    ),
                                                    child: const Text('删除'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: '删除',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(WorkLogEntry entry) {
    TimeOfDay startTime = entry.startTime;
    TimeOfDay endTime = entry.endTime;
    final contentController = TextEditingController(text: entry.content);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('编辑工作记录'),
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

                  final updatedEntry = entry.copyWith(
                    startTime: startTime,
                    endTime: endTime,
                    content: contentController.text.trim(),
                  );

                  _handleUpdate(updatedEntry);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136dec),
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
}

