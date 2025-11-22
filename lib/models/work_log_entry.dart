import 'package:flutter/material.dart';

class WorkLogEntry {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String content;

  WorkLogEntry({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.content,
  });

  // 从JSON创建对象
  factory WorkLogEntry.fromJson(Map<String, dynamic> json) {
    return WorkLogEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'] as int,
        minute: json['startTime']['minute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'] as int,
        minute: json['endTime']['minute'] as int,
      ),
      content: json['content'] as String,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // 只保存日期部分
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'content': content,
    };
  }

  // 复制方法，用于编辑
  WorkLogEntry copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? content,
  }) {
    return WorkLogEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      content: content ?? this.content,
    );
  }

  // 格式化时间段显示
  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

