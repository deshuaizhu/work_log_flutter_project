import 'package:get/get.dart';
import '../services/storage_service.dart';

/// 工作日志共享数据控制器
/// 管理所有 Controller 共享的数据，如所有有日志的日期集合
class WorkLogDataController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  /// 所有有日志的日期集合（共享数据）
  final datesWithEntries = <DateTime>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDatesWithEntries();
    
    // 监听数据源变化，自动刷新共享数据
    ever(_storageService.dataChanged, (_) {
      loadDatesWithEntries();
    });
  }

  /// 加载所有有日志的日期集合
  void loadDatesWithEntries() {
    final dates = _storageService.getDatesWithEntries();
    datesWithEntries.assignAll(dates);
  }
}

