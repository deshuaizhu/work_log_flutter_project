import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/work_log_entry.dart';

class StorageService extends GetxService {
  List<WorkLogEntry> _entries = [];
  File? _file;
  File? _configFile;
  
  // 数据变更通知，用于通知所有控制器刷新数据
  final dataChanged = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _init();
  }

  // 获取配置文件路径
  Future<File> _getConfigFile() async {
    if (_configFile != null) return _configFile!;
    final directory = await getApplicationSupportDirectory();
    _configFile = File('${directory.path}/config.json');
    return _configFile!;
  }

  // 读取配置文件
  Future<String?> _readConfigPath() async {
    try {
      final configFile = await _getConfigFile();
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> config = json.decode(content);
          return config['dataSourcePath'] as String?;
        }
      }
    } catch (e) {
      debugPrint('读取配置文件失败: $e');
    }
    return null;
  }

  // 保存配置文件
  Future<void> _saveConfigPath(String filePath) async {
    try {
      final configFile = await _getConfigFile();
      final config = {'dataSourcePath': filePath};
      await configFile.writeAsString(json.encode(config));
    } catch (e) {
      debugPrint('保存配置文件失败: $e');
    }
  }

  // 初始化存储服务
  Future<void> _init() async {
    try {
      // 优先读取配置文件中的自定义路径
      String? customPath = await _readConfigPath();
      
      if (customPath != null && await File(customPath).exists()) {
        _file = File(customPath);
      } else {
        // 使用默认路径
        final directory = await getApplicationSupportDirectory();
        _file = File('${directory.path}/work_logs.json');
      }
      
      await _loadData();
    } catch (e) {
      debugPrint('初始化存储服务失败: $e');
    }
  }

  // 加载数据
  Future<void> _loadData() async {
    try {
      if (_file != null) {
        if (await _file!.exists()) {
          final content = await _file!.readAsString();
          if (content.isNotEmpty) {
            final List<dynamic> jsonList = json.decode(content);
            _entries = jsonList.map((json) => WorkLogEntry.fromJson(json)).toList();
          } else {
            _entries = [];
          }
        } else {
          // 如果文件不存在，创建它
          await _file!.create(recursive: true);
          _entries = [];
          await _save();
        }
      }
    } catch (e) {
      debugPrint('加载数据失败: $e');
      _entries = [];
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

  // 获取当前文件路径
  String? getCurrentFilePath() {
    return _file?.path;
  }

  // 切换数据源并重新加载数据
  Future<bool> changeDataSource(String filePath) async {
    try {
      // 验证文件是否存在
      final newFile = File(filePath);
      if (!await newFile.exists()) {
        debugPrint('文件不存在: $filePath');
        return false;
      }

      // 验证文件是否为有效的 JSON 格式
      try {
        final content = await newFile.readAsString();
        if (content.isNotEmpty) {
          json.decode(content) as List;
        }
      } catch (e) {
        debugPrint('文件格式无效: $e');
        return false;
      }

      // 保存新路径到配置文件
      await _saveConfigPath(filePath);

      // 更新文件引用
      _file = newFile;

      // 重新加载数据
      await _loadData();
      
      // 通知所有控制器数据已变更
      dataChanged.value++;

      return true;
    } catch (e) {
      debugPrint('切换数据源失败: $e');
      return false;
    }
  }

  // 重新加载数据
  Future<void> reloadData() async {
    await _loadData();
  }

  // 获取所有有日志的日期集合
  Set<DateTime> getDatesWithEntries() {
    final Set<DateTime> dates = {};
    for (final entry in _entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dates.add(date);
    }
    return dates;
  }
}

