import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/main_controller.dart';
import 'widgets/sidebar.dart';
import 'pages/today_page.dart';
import 'pages/history_page.dart';
import 'pages/export_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化（中文）
  await initializeDateFormatting('zh_CN', null);

  // 初始化并注册存储服务（使用 putAsync 等待异步初始化完成）
  await Get.putAsync<StorageService>(() async {
    final service = StorageService();
    await service.onInit();
    return service;
  }, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WorkLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF136dec),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFFf6f7f8),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF136dec),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101822),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      // 添加本地化支持
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文简体
        Locale('en', 'US'), // 英文（美国）
      ],
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    Widget buildContent() {
      return Obx(() {
        switch (controller.selectedMenuItem.value) {
          case MenuItem.today:
            return const TodayPage();
          case MenuItem.history:
            return const HistoryPage();
          case MenuItem.export:
            return const ExportPage();
        }
      });
    }

    return Scaffold(
      body: Row(
        children: [
          // 左侧菜单
          Obx(() => Sidebar(
                selectedItem: controller.selectedMenuItem.value,
                onItemSelected: controller.selectMenuItem,
              )),
          // 右侧内容区
          Expanded(
            child: buildContent(),
          ),
        ],
      ),
    );
  }
}
