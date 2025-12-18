import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';

class DataSourceController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final currentFilePath = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _updateFilePath();
  }

  // 更新文件路径显示
  void _updateFilePath() {
    final path = _storageService.getCurrentFilePath();
    currentFilePath.value = path ?? '未设置';
  }

  // 选择文件
  Future<void> selectFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: '选择工作记录文件',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _changeDataSource(filePath);
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '选择文件失败：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 切换数据源
  Future<void> _changeDataSource(String filePath) async {
    isLoading.value = true;
    
    try {
      final success = await _storageService.changeDataSource(filePath);
      
      if (success) {
        _updateFilePath();
        Get.snackbar(
          '成功',
          '数据源已切换，数据已重新加载',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '错误',
          '切换数据源失败：文件不存在或格式无效',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '切换数据源失败：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

