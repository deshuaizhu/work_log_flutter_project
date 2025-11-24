import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final StorageService _storageService = StorageService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _updateTitleFromDate();
    _updateFileNameFromDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  void _updateTitleFromDate() {
    final year = _endDate.year;
    final month = _endDate.month;
    _titleController.text = '$year年$month月Monthly Report';
  }

  String _getUsername() {
    // 尝试从环境变量获取用户名
    final username = Platform.environment['USERNAME'] ?? 
                    Platform.environment['USER'] ?? 
                    'User';
    return username;
  }

  void _updateFileNameFromDate() {
    final year = _endDate.year;
    final month = _endDate.month;
    final username = _getUsername();
    _fileNameController.text = 'FMS-$username-$year年$month月-monthly report';
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF136dec),
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
        _updateTitleFromDate();
        _updateFileNameFromDate();
      });
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF136dec),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _updateTitleFromDate();
        _updateFileNameFromDate();
      });
    }
  }

  String _generateMarkdown() {
    final entries = _storageService.getEntriesGroupedByDate(_startDate, _endDate);
    final sortedDates = entries.keys.toList()..sort((a, b) => a.compareTo(b));
    
    final buffer = StringBuffer();
    
    // 标题
    if (_titleController.text.trim().isNotEmpty) {
      buffer.writeln('# ${_titleController.text.trim()}');
      buffer.writeln();
      buffer.writeln();
    }
    
    // 按日期分组输出
    for (final date in sortedDates) {
      final dateStr = DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
      buffer.writeln('### $dateStr');
      buffer.writeln();
      
      final dayEntries = entries[date]!;
      for (final entry in dayEntries) {
        buffer.writeln('${entry.timeRange} ${entry.content}');
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }

  Future<void> _exportToFile() async {
    if (_fileNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文件名不能为空'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // 使用file_picker选择保存位置
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存工作记录',
        fileName: '${_fileNameController.text.trim()}.md',
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (outputPath != null) {
        final content = _generateMarkdown();
        final file = File(outputPath);
        await file.writeAsString(content, encoding: utf8);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导出成功：$outputPath'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败：$e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '导出工作记录',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '配置您的Markdown导出设置。',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 设置区域
              Container(
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  '导出设置',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 表单
              Column(
                children: [
                  // 导出标题和文件名
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '导出标题',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: '例如：每周进度报告',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1c2027) : Colors.white,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '文件名称',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            TextField(
                              controller: _fileNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1c2027) : Colors.white,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 日期范围
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '日期范围',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectStartDate,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? const Color(0xFF1c2027) : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatDate(_startDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectEndDate,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? const Color(0xFF1c2027) : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatDate(_endDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 导出按钮
              Container(
                padding: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportToFile,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isExporting ? '导出中...' : '导出'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136dec),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '将导出为Markdown (.md) 文件。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

