import 'package:get/get.dart';
import '../models/work_log_entry.dart';
import '../services/storage_service.dart';
import 'work_log_data_controller.dart';

class HistoryController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final WorkLogDataController _dataController = Get.find<WorkLogDataController>();
  
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final groupedEntries = <DateTime, List<WorkLogEntry>>{}.obs;

  /// 访问共享数据：所有有日志的日期集合
  Set<DateTime> get datesWithEntries => _dataController.datesWithEntries.toSet();

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
    final grouped = _storageService.getEntriesGroupedByDate(
      startDate.value,
      endDate.value,
    );
    groupedEntries.value = grouped;
  }

  Future<void> selectStartDate(DateTime date) async {
    if (date != startDate.value) {
      startDate.value = date;
      if (startDate.value.isAfter(endDate.value)) {
        endDate.value = startDate.value;
      }
      await loadEntries();
    }
  }

  Future<void> selectEndDate(DateTime date) async {
    if (date != endDate.value) {
      endDate.value = date;
      await loadEntries();
    }
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

