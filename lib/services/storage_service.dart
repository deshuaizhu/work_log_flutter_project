import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/work_log_entry.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  List<WorkLogEntry> _entries = [];
  File? _file;

  // 初始化存储服务
  Future<void> init() async {
    try {
      final directory = await getApplicationSupportDirectory();
      _file = File('${directory.path}/work_logs.json');
      
      if (await _file!.exists()) {
        final content = await _file!.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(content);
          _entries = jsonList.map((json) => WorkLogEntry.fromJson(json)).toList();
        }
      } else {
        await _file!.create(recursive: true);
        await _save();
      }
    } catch (e) {
      debugPrint('初始化存储服务失败: $e');
    }
  }

  // 保存到文件
  Future<void> _save() async {
    try {
      if (_file != null) {
        final jsonList = _entries.map((entry) => entry.toJson()).toList();
        await _file!.writeAsString(json.encode(jsonList));
      }
    } catch (e) {
      debugPrint('保存数据失败: $e');
    }
  }

  // 添加工作记录
  Future<void> addEntry(WorkLogEntry entry) async {
    _entries.add(entry);
    await _save();
  }

  // 更新工作记录
  Future<void> updateEntry(WorkLogEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      await _save();
    }
  }

  // 删除工作记录
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
  }

  // 获取所有记录
  List<WorkLogEntry> getAllEntries() {
    return List.unmodifiable(_entries);
  }

  // 根据日期获取记录
  List<WorkLogEntry> getEntriesByDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _entries.where((entry) {
      final entryDateStr = entry.date.toIso8601String().split('T')[0];
      return entryDateStr == dateStr;
    }).toList()
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  // 根据日期范围获取记录
  List<WorkLogEntry> getEntriesByDateRange(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    
    return _entries.where((entry) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return entryDate.isAfter(start.subtract(const Duration(days: 1))) &&
             entryDate.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) {
        // 先按日期排序
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        // 同一天按时间排序
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  // 按日期分组
  Map<DateTime, List<WorkLogEntry>> getEntriesGroupedByDate(DateTime startDate, DateTime endDate) {
    final entries = getEntriesByDateRange(startDate, endDate);
    final Map<DateTime, List<WorkLogEntry>> grouped = {};
    
    for (final entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }
    
    return grouped;
  }
}

