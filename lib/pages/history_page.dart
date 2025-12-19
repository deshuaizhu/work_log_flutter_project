import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import '../models/work_log_entry.dart';
import '../widgets/time_range_picker.dart';
import '../widgets/custom_date_picker.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String formatDate(DateTime date) {
    final weekday = DateFormat('EEEE', 'zh_CN').format(date);
    return '${DateFormat('yyyy年MM月dd日', 'zh_CN').format(date)} $weekday';
  }

  String formatDateShort(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  Future<void> selectStartDate(HistoryController controller) async {
    final DateTime? picked = await showCustomDatePicker(
      context: Get.context!,
      initialDate: controller.startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      datesWithEntries: controller.datesWithEntries.toSet(),
    );
    
    if (picked != null) {
      await controller.selectStartDate(picked);
    }
  }


  Future<void> selectEndDate(HistoryController controller) async {
    final DateTime? picked = await showCustomDatePicker(
      context: Get.context!,
      initialDate: controller.endDate.value,
      firstDate: controller.startDate.value,
      lastDate: DateTime.now(),
      datesWithEntries: controller.datesWithEntries.toSet(),
    );
    
    if (picked != null) {
      await controller.selectEndDate(picked);
    }
  }

  void showEditDialog(HistoryController controller, WorkLogEntry entry) {
    TimeOfDay startTime = entry.startTime;
    TimeOfDay endTime = entry.endTime;
    final contentController = TextEditingController(text: entry.content);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('编辑工作记录'),
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

                  final updatedEntry = entry.copyWith(
                    startTime: startTime,
                    endTime: endTime,
                    content: contentController.text.trim(),
                  );

                  controller.updateEntry(updatedEntry);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136dec),
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
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
                  const Text(
                    '历史记录',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // 日期范围选择器
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isDark ? const Color(0xFF19212b) : Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 20,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => selectStartDate(controller),
                              child: Text(
                                formatDateShort(controller.startDate.value),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Text(' - '),
                            InkWell(
                              onTap: () => selectEndDate(controller),
                              child: Text(
                                formatDateShort(controller.endDate.value),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 工作记录列表
              Obx(() {
                final sortedDates = controller.groupedEntries.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                
                if (controller.groupedEntries.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(80),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off,
                                size: 32,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '未找到记录',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '所选时段内没有工作日志条目。',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Expanded(
                    child: ListView(
                      children: sortedDates.map((date) {
                        final entries = controller.groupedEntries[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 日期标题
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  formatDate(date),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                            
                            // 该日期的工作记录
                            ...entries.map((entry) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // 图标
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.schedule,
                                          size: 24,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // 内容和时间
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.timeRange,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              entry.content,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // 操作按钮
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () {
                                              showEditDialog(controller, entry);
                                            },
                                            tooltip: '编辑',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            color: Colors.red[400],
                                            onPressed: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text('确认删除'),
                                                  content: const Text('确定要删除这条工作记录吗？'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Get.back(),
                                                      child: const Text('取消'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                        controller.deleteEntry(entry.id);
                                                      },
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.red,
                                                      ),
                                                      child: const Text('删除'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            tooltip: '删除',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        );
                      }).toList(),
                    ),
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
