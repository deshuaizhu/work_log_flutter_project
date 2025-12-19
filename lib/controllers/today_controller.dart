import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/work_log_entry.dart';
import '../services/storage_service.dart';
import 'work_log_data_controller.dart';

class TodayController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final selectedDate = DateTime.now().obs;
  final entries = <WorkLogEntry>[].obs;

  DateTime get today => DateTime.now();

  bool get isToday {
    final today = this.today;
    return selectedDate.value.year == today.year &&
        selectedDate.value.month == today.month &&
        selectedDate.value.day == today.day;
  }

  /// 访问共享数据：所有有日志的日期集合
  Set<DateTime> get datesWithEntries {
    try {
      final dataController = Get.find<WorkLogDataController>();
      return dataController.datesWithEntries.toSet();
    } catch (e) {
      // 如果 WorkLogDataController 还未初始化，返回空集合
      return <DateTime>{};
    }
  }
  

  @override
  void onInit() {
    super.onInit();
    loadEntries();
    
    // 监听数据源变化，自动刷新数据
    ever(_storageService.dataChanged, (_) {
      loadEntries();
    });
  }

  Future<void> loadEntries() async {
    final loadedEntries = _storageService.getEntriesByDate(selectedDate.value);
    entries.value = loadedEntries;
  }

  Future<void> selectDate(DateTime date) async {
    if (date != selectedDate.value) {
      selectedDate.value = date;
      await loadEntries();
    }
  }

  void resetToToday() {
    selectedDate.value = today;
    loadEntries();
  }

  (TimeOfDay, TimeOfDay) getDefaultTimes() {
    if (entries.isEmpty) {
      return (
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 9, minute: 30)
      );
    }

    final sortedEntries = List<WorkLogEntry>.from(entries)
      ..sort((a, b) {
        final aMinutes = a.endTime.hour * 60 + a.endTime.minute;
        final bMinutes = b.endTime.hour * 60 + b.endTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    final lastEntry = sortedEntries.last;
    final lastEndTime = lastEntry.endTime;

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

  Future<void> addEntry({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String content,
  }) async {
    final entry = WorkLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: selectedDate.value,
      startTime: startTime,
      endTime: endTime,
      content: content,
    );

    await _storageService.addEntry(entry);
    await loadEntries();
  }

  Future<void> updateEntry(WorkLogEntry entry) async {
    await _storageService.updateEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _storageService.deleteEntry(id);
    await loadEntries();
  }
}

