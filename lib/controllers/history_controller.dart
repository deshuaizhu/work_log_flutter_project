import 'package:get/get.dart';
import '../models/work_log_entry.dart';
import '../services/storage_service.dart';

class HistoryController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final groupedEntries = <DateTime, List<WorkLogEntry>>{}.obs;
  final datesWithEntries = <DateTime>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadEntries();
    loadDatesWithEntries();
    
    // 监听数据源变化，自动刷新数据
    ever(_storageService.dataChanged, (_) {
      loadEntries();
      loadDatesWithEntries();
    });
  }

  void loadDatesWithEntries() {
    final dates = _storageService.getDatesWithEntries();
    datesWithEntries.assignAll(dates);
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
    loadDatesWithEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _storageService.deleteEntry(id);
    await loadEntries();
    loadDatesWithEntries();
  }
}

