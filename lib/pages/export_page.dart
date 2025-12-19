import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/export_controller.dart';
import '../widgets/custom_date_picker.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  String formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  Future<void> selectStartDate(ExportController controller) async {
    final DateTime? picked = await showCustomDatePicker(
      context: Get.context!,
      initialDate: controller.startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await controller.selectStartDate(picked);
    }
  }

  Future<void> selectEndDate(ExportController controller) async {
    final DateTime? picked = await showCustomDatePicker(
      context: Get.context!,
      initialDate: controller.endDate.value,
      firstDate: controller.startDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await controller.selectEndDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExportController());
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '导出工作记录',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '配置您的Markdown导出设置。',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 设置区域
              Container(
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  '导出设置',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 表单
              Column(
                children: [
                  // 导出标题和文件名
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '导出标题',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            TextField(
                                  controller: controller.titleController,
                                  decoration: InputDecoration(
                                    hintText: '例如：每周进度报告',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1c2027) : Colors.white,
                                    contentPadding: const EdgeInsets.all(15),
                                  ),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '文件名称',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            TextField(
                                  controller: controller.fileNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1c2027) : Colors.white,
                                    contentPadding: const EdgeInsets.all(15),
                                  ),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 日期范围
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '日期范围',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => InkWell(
                                  onTap: () => selectStartDate(controller),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isDark ? const Color(0xFF1c2027) : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          formatDate(controller.startDate.value),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => InkWell(
                                  onTap: () => selectEndDate(controller),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isDark ? const Color(0xFF1c2027) : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          formatDate(controller.endDate.value),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 导出按钮
              Container(
                padding: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => ElevatedButton.icon(
                          onPressed: controller.isExporting.value ? null : controller.exportToFile,
                          icon: controller.isExporting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(controller.isExporting.value ? '导出中...' : '导出'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF136dec),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
                    const SizedBox(height: 8),
                    Text(
                      '将导出为Markdown (.md) 文件。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
