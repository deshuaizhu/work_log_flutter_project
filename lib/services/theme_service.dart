import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class ThemeService extends GetxService {
  final themeMode = ThemeMode.system.obs;
  File? _configFile;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadThemeMode();
  }

  // 获取配置文件路径
  Future<File> _getConfigFile() async {
    if (_configFile != null) return _configFile!;
    final directory = await getApplicationSupportDirectory();
    _configFile = File('${directory.path}/config.json');
    return _configFile!;
  }

  // 读取主题模式
  Future<void> _loadThemeMode() async {
    try {
      final configFile = await _getConfigFile();
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> config = json.decode(content);
          final themeModeStr = config['themeMode'] as String?;
          if (themeModeStr != null) {
            switch (themeModeStr) {
              case 'light':
                themeMode.value = ThemeMode.light;
                break;
              case 'dark':
                themeMode.value = ThemeMode.dark;
                break;
              case 'system':
              default:
                themeMode.value = ThemeMode.system;
                break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('读取主题配置失败: $e');
    }
  }

  // 保存主题模式
  Future<void> _saveThemeMode() async {
    try {
      final configFile = await _getConfigFile();
      Map<String, dynamic> config = {};
      
      // 如果配置文件已存在，先读取现有配置
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        if (content.isNotEmpty) {
          config = json.decode(content) as Map<String, dynamic>;
        }
      }
      
      // 更新主题模式
      String themeModeStr;
      switch (themeMode.value) {
        case ThemeMode.light:
          themeModeStr = 'light';
          break;
        case ThemeMode.dark:
          themeModeStr = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeModeStr = 'system';
          break;
      }
      
      config['themeMode'] = themeModeStr;
      await configFile.writeAsString(json.encode(config));
    } catch (e) {
      debugPrint('保存主题配置失败: $e');
    }
  }

  // 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _saveThemeMode();
  }

  // 切换黑夜模式（在亮色和暗色之间切换，不包括系统模式）
  Future<void> toggleDarkMode() async {
    if (themeMode.value == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  // 获取是否为黑夜模式
  bool get isDarkMode {
    return themeMode.value == ThemeMode.dark;
  }
}

