// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/today_controller.dart';
import '../models/work_log_entry.dart';
import '../widgets/work_log_item.dart';
import '../widgets/time_range_picker.dart';
import '../widgets/custom_date_picker.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  String formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  void showAddDialog(TodayController controller) {
    final (defaultStartTime, defaultEndTime) = controller.getDefaultTimes();
    TimeOfDay startTime = defaultStartTime;
    TimeOfDay endTime = defaultEndTime;
    final contentController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('添加工作记录'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间选择器
                  TimeRangePicker(
                    initialStartTime: startTime,
                    initialEndTime: endTime,
                    onTimeSelected: (start, end) {
                      setDialogState(() {
                        startTime = start;
                        endTime = end;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 内容输入框
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '请输入工作内容',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (contentController.text.trim().isEmpty) {
                    Get.snackbar(
                      '错误',
                      '工作内容不能为空',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }

                  controller.addEntry(
                    startTime: startTime,
                    endTime: endTime,
                    content: contentController.text.trim(),
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136dec),
                  foregroundColor: Colors.white,
                ),
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> selectDate(TodayController controller) async {
    final DateTime? picked = await showCustomDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await controller.selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodayController());
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Obx(() => Text(
                            formatDate(controller.selectedDate.value),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () => selectDate(controller),
                        tooltip: '选择日期',
                      ),
                      Obx(() => controller.isToday
                          ? const SizedBox.shrink()
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: '重置到今日',
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    onPressed: controller.resetToToday,
                                    tooltip: '重置到今日',
                                  ),
                                ),
                              ],
                            )),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showAddDialog(controller),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('添加记录'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF136dec),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 工作记录列表
              Obx(() {
                if (controller.entries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.isToday
                                ? '今天还没有工作记录'
                                : '${formatDate(controller.selectedDate.value)}还没有工作记录',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击"添加记录"按钮开始记录您的工作',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: controller.entries.map((entry) => WorkLogItem(
                          entry: entry,
                          onDelete: () => controller.deleteEntry(entry.id),
                          onUpdate: controller.updateEntry,
                        )).toList(),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
