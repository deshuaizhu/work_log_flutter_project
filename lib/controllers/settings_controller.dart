import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = Get.find<ThemeService>();
  
  // 是否为黑夜模式（响应式）
  RxBool get isDarkMode => _themeService.isDarkMode.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听主题模式变化
    ever(_themeService.themeMode, (_) {
      update();
    });
  }

  // 切换黑夜模式
  Future<void> toggleDarkMode(bool value) async {
    if (value) {
      await _themeService.setThemeMode(ThemeMode.dark);
    } else {
      await _themeService.setThemeMode(ThemeMode.light);
    }
  }

  // 获取当前主题模式
  ThemeMode get currentThemeMode => _themeService.themeMode.value;
}

