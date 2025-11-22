import 'package:flutter/material.dart';

class TimeRangePicker extends StatefulWidget {
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final Function(TimeOfDay startTime, TimeOfDay endTime) onTimeSelected;

  const TimeRangePicker({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
    required this.onTimeSelected,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.initialStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    endTime = widget.initialEndTime ?? const TimeOfDay(hour: 18, minute: 0);
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF136dec),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
        // 如果开始时间晚于结束时间，自动调整结束时间
        if (_compareTime(startTime, endTime) >= 0) {
          endTime = TimeOfDay(
            hour: (startTime.hour + 1) % 24,
            minute: startTime.minute,
          );
        }
      });
      widget.onTimeSelected(startTime, endTime);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF136dec),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != endTime) {
      // 验证结束时间必须晚于开始时间
      if (_compareTime(startTime, picked) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('结束时间必须晚于开始时间'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() {
        endTime = picked;
      });
      widget.onTimeSelected(startTime, endTime);
    }
  }

  int _compareTime(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // 开始时间
        InkWell(
          onTap: _selectStartTime,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? const Color(0xFF1c2027) : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(startTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        
        // 结束时间
        InkWell(
          onTap: _selectEndTime,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? const Color(0xFF3b4554) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? const Color(0xFF1c2027) : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(endTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

