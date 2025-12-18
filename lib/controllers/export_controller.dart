import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class ExportController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final titleController = TextEditingController();
  final fileNameController = TextEditingController();
  final startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  final endDate = DateTime.now().obs;
  final isExporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    updateTitleFromDate();
    updateFileNameFromDate();
  }

  @override
  void onClose() {
    titleController.dispose();
    fileNameController.dispose();
    super.onClose();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  void updateTitleFromDate() {
    final year = endDate.value.year;
    final month = endDate.value.month;
    titleController.text = '$year年$month月Monthly Report';
  }

  String getUsername() {
    final username = Platform.environment['USERNAME'] ?? 
                    Platform.environment['USER'] ?? 
                    'User';
    return username;
  }

  void updateFileNameFromDate() {
    final year = endDate.value.year;
    final month = endDate.value.month;
    final username = getUsername();
    fileNameController.text = 'FMS-$username-$year年$month月-monthly report';
  }

  Future<void> selectStartDate(DateTime date) async {
    if (date != startDate.value) {
      startDate.value = date;
      if (startDate.value.isAfter(endDate.value)) {
        endDate.value = startDate.value;
      }
      updateTitleFromDate();
      updateFileNameFromDate();
    }
  }

  Future<void> selectEndDate(DateTime date) async {
    if (date != endDate.value) {
      endDate.value = date;
      updateTitleFromDate();
      updateFileNameFromDate();
    }
  }

  String generateMarkdown() {
    final entries = _storageService.getEntriesGroupedByDate(
      startDate.value,
      endDate.value,
    );
    final sortedDates = entries.keys.toList()..sort((a, b) => a.compareTo(b));
    
    final buffer = StringBuffer();
    
    if (titleController.text.trim().isNotEmpty) {
      buffer.writeln('# ${titleController.text.trim()}');
      buffer.writeln();
      buffer.writeln();
    }
    
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

  Future<void> exportToFile() async {
    if (fileNameController.text.trim().isEmpty) {
      Get.snackbar(
        '错误',
        '文件名不能为空',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isExporting.value = true;

    try {
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存工作记录',
        fileName: '${fileNameController.text.trim()}.md',
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (outputPath != null) {
        final content = generateMarkdown();
        final file = File(outputPath);
        await file.writeAsString(content, encoding: utf8);

        Get.snackbar(
          '成功',
          '导出成功：$outputPath',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '导出失败：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }
}

