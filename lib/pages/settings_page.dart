import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
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
                    '设置',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '管理您的应用设置。',
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
                  '外观设置',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 黑夜模式开关
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? const Color(0xFF1c2027) : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          size: 24,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '黑夜模式',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '切换应用的黑夜模式',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(() {
                      final themeService = Get.find<ThemeService>();
                      // 判断开关状态：如果是 dark 模式则为 true，如果是 system 模式则根据系统当前主题判断
                      bool switchValue;
                      if (themeService.themeMode.value == ThemeMode.dark) {
                        switchValue = true;
                      } else if (themeService.themeMode.value == ThemeMode.light) {
                        switchValue = false;
                      } else {
                        // system 模式：根据当前实际主题判断
                        switchValue = Theme.of(context).brightness == Brightness.dark;
                      }
                      
                      return Switch(
                        value: switchValue,
                        onChanged: (value) {
                          controller.toggleDarkMode(value);
                        },
                        activeColor: const Color(0xFF136dec),
                      );
                    }),
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

