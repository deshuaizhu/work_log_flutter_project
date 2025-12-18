import 'package:flutter/material.dart';

enum MenuItem { today, history, export, dataSource, settings }

class Sidebar extends StatelessWidget {
  final MenuItem selectedItem;
  final Function(MenuItem) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 256,
      color: isDark ? const Color(0xFF19212b) : Colors.white,
      child: Column(
        children: [
          // Logo和标题区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF136dec),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WorkLog',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '记录您的工作',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 导航菜单
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.today,
                  label: '今日',
                  item: MenuItem.today,
                  isSelected: selectedItem == MenuItem.today,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context: context,
                  icon: Icons.history,
                  label: '历史',
                  item: MenuItem.history,
                  isSelected: selectedItem == MenuItem.history,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context: context,
                  icon: Icons.download,
                  label: '导出',
                  item: MenuItem.export,
                  isSelected: selectedItem == MenuItem.export,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context: context,
                  icon: Icons.storage,
                  label: '数据源',
                  item: MenuItem.dataSource,
                  isSelected: selectedItem == MenuItem.dataSource,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  label: '设置',
                  item: MenuItem.settings,
                  isSelected: selectedItem == MenuItem.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required MenuItem item,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF136dec);
    
    return InkWell(
      onTap: () => onItemSelected(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

