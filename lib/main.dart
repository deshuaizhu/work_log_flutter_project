import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/sidebar.dart';
import 'pages/today_page.dart';
import 'pages/history_page.dart';
import 'pages/export_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化（中文）
  await initializeDateFormatting('zh_CN', null);

  // 初始化存储服务
  await StorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MenuItem _selectedMenuItem = MenuItem.today;

  void _handleMenuSelection(MenuItem item) {
    setState(() {
      _selectedMenuItem = item;
    });
  }

  Widget _buildContent() {
    switch (_selectedMenuItem) {
      case MenuItem.today:
        return const TodayPage();
      case MenuItem.history:
        return const HistoryPage();
      case MenuItem.export:
        return const ExportPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧菜单
          Sidebar(
            selectedItem: _selectedMenuItem,
            onItemSelected: _handleMenuSelection,
          ),
          // 右侧内容区
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
