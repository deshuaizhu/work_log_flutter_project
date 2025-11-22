import 'package:flutter/material.dart';
import '../models/work_log_entry.dart';
import 'time_range_picker.dart';

class WorkLogItem extends StatefulWidget {
  final WorkLogEntry entry;
  final VoidCallback onDelete;
  final Function(WorkLogEntry) onUpdate;

  const WorkLogItem({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<WorkLogItem> createState() => _WorkLogItemState();
}

class _WorkLogItemState extends State<WorkLogItem> {
  bool _isEditing = false;
  late TextEditingController _contentController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
    _startTime = widget.entry.startTime;
    _endTime = widget.entry.endTime;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _contentController.text = widget.entry.content;
      _startTime = widget.entry.startTime;
      _endTime = widget.entry.endTime;
    });
  }

  void _saveEdit() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('工作内容不能为空'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final updatedEntry = widget.entry.copyWith(
      startTime: _startTime,
      endTime: _endTime,
      content: _contentController.text.trim(),
    );

    widget.onUpdate(updatedEntry);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isEditing) {
      return _buildEditMode(context, isDark);
    }
    
    return _buildViewMode(context, isDark);
  }

  Widget _buildViewMode(BuildContext context, bool isDark) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF19212b) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 时间段
            SizedBox(
              width: 128,
              child: Text(
                widget.entry.timeRange,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 内容
            Expanded(
              child: Text(
                widget.entry.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
            ),
            
            // 操作按钮（hover时显示）
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  onPressed: _startEdit,
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
                              widget.onDelete();
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
      ),
    );
  }

  Widget _buildEditMode(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF19212b) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF136dec),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间选择器
          TimeRangePicker(
            initialStartTime: _startTime,
            initialEndTime: _endTime,
            onTimeSelected: (start, end) {
              setState(() {
                _startTime = start;
                _endTime = end;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 内容输入框
          TextField(
            controller: _contentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '请输入工作内容',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                ),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1c2027) : Colors.grey[50],
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelEdit,
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136dec),
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

