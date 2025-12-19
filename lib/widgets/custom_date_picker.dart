import 'package:flutter/material.dart';

/// 显示自定义日期选择器对话框
/// 
/// [context] 构建上下文
/// [initialDate] 初始选中的日期
/// [firstDate] 可选择的最早日期
/// [lastDate] 可选择的最晚日期
/// [datesWithEntries] 可选，有日志的日期集合，用于显示蓝色圆点标识
/// 
/// 返回选中的日期，如果用户取消则返回 null
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Set<DateTime>? datesWithEntries,
}) async {
  DateTime selectedDate = initialDate;
  DateTime currentMonth = DateTime(initialDate.year, initialDate.month, 1);
  
  return await showDialog<DateTime>(
    context: context,
    builder: (context) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF136dec),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 350,
                child: _buildCustomCalendar(
                  context,
                  selectedDate,
                  currentMonth,
                  firstDate,
                  lastDate,
                  datesWithEntries ?? {},
                  (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  (month) {
                    setState(() {
                      currentMonth = month;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136dec),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

/// 构建自定义日历视图
Widget _buildCustomCalendar(
  BuildContext context,
  DateTime selectedDate,
  DateTime currentMonth,
  DateTime firstDate,
  DateTime lastDate,
  Set<DateTime> datesWithEntries,
  Function(DateTime) onDateSelected,
  Function(DateTime) onMonthChanged,
) {
  final now = DateTime.now();
  
  // 获取月份的第一天是星期几 (0 = Sunday, 6 = Saturday)
  int firstDayOfWeek = currentMonth.weekday % 7;
  
  // 获取月份的天数
  int daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  
  // 星期标题
  final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
  
  // 计算是否可以切换到上一个月
  bool canGoPrevious = currentMonth.isAfter(DateTime(firstDate.year, firstDate.month, 1));
  // 计算是否可以切换到下一个月
  DateTime nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  bool canGoNext = nextMonth.isBefore(DateTime(lastDate.year, lastDate.month + 1, 1));
  
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 月份导航
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: canGoPrevious ? () {
              DateTime prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
              onMonthChanged(prevMonth);
            } : null,
          ),
          Text(
            '${currentMonth.year}年${currentMonth.month}月',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoNext ? () {
              onMonthChanged(nextMonth);
            } : null,
          ),
        ],
      ),
      const SizedBox(height: 16),
      // 星期标题
      Table(
        children: [
          TableRow(
            children: weekDays.map((day) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )).toList(),
          ),
          // 日期行
          ...List.generate((firstDayOfWeek + daysInMonth + 6) ~/ 7, (weekIndex) {
            return TableRow(
              children: List.generate(7, (dayIndex) {
                int dayNumber = weekIndex * 7 + dayIndex - firstDayOfWeek + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }
                
                DateTime date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                final dateOnly = DateTime(date.year, date.month, date.day);
                final hasEntry = datesWithEntries.any(
                  (d) => d.year == dateOnly.year && 
                         d.month == dateOnly.month && 
                         d.day == dateOnly.day
                );
                
                final isSelected = dateOnly.year == selectedDate.year &&
                    dateOnly.month == selectedDate.month &&
                    dateOnly.day == selectedDate.day;
                
                final isToday = dateOnly.year == now.year &&
                    dateOnly.month == now.month &&
                    dateOnly.day == now.day;
                
                final isDisabled = date.isAfter(lastDate) || date.isBefore(firstDate);
                
                return GestureDetector(
                  onTap: isDisabled ? null : () => onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? const Color(0xFF136dec)
                          : isToday
                              ? const Color(0xFF136dec).withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey[400]
                                  : isSelected
                                      ? Colors.white
                                      : Colors.black87,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasEntry && !isSelected)
                          Positioned(
                            top: 2,
                            left: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF136dec),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    ],
  );
}

