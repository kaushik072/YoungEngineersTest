import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AttendanceRecord {
  final int id;
  final int groupId;
  final int posId;
  final int studentId;
  final int lessonId;
  final String date;
  final String day;
  final String status;
  final String createdAt;
  final String updatedAt;

  AttendanceRecord({
    required this.id,
    required this.groupId,
    required this.posId,
    required this.studentId,
    required this.lessonId,
    required this.date,
    required this.day,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      posId: json['pos_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      lessonId: json['lesson_id'] ?? 0,
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class AttendanceData {
  final String date;
  final Map<int, AttendanceGroupData> groupData;

  AttendanceData({required this.date, required this.groupData});

  // Get total percentage across all groups
  double get totalPercentage {
    if (groupData.isEmpty) return 0.0;
    double sum = groupData.values.fold(
      0.0,
      (sum, group) => sum + group.percentage,
    );
    return sum / groupData.length;
  }

  // Get formatted date for display
  String get formattedDate {
    try {
      if (date.contains('-')) {
        return date; // Weekly date range format
      } else {
        final DateTime dateTime = DateFormat('dd\nMMM').parse(date);
        return DateFormat('dd\nMMM').format(dateTime);
      }
    } catch (e) {
      return date;
    }
  }
}

class AttendanceGroupData {
  final int groupId;
  final int posId;
  final int totalStudents;
  final int presentStudents;
  final double percentage;

  AttendanceGroupData({
    required this.groupId,
    required this.posId,
    required this.totalStudents,
    required this.presentStudents,
  }) : percentage =
           totalStudents > 0 ? (presentStudents * 100 / totalStudents) : 0.0;

  // Get color based on groupId
  Color get color {
    switch (groupId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get position name based on posId
  String get positionName => posId == 1 ? 'Position 1' : 'Position 2';
}

class BarData {
  final double value;
  final Color color;
  final int groupId;

  BarData({required this.value, required this.color, required this.groupId});
}

class ApiExceptionData implements Exception {
  final String message;
  final int? statusCode;

  ApiExceptionData(this.message, this.statusCode);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
}

class AttendanceResponse {
  final bool success;
  final String message;
  final List<AttendanceRecord> data;

  AttendanceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)
              ?.map((record) => AttendanceRecord.fromJson(record))
              .toList() ??
          [],
    );
  }
}
