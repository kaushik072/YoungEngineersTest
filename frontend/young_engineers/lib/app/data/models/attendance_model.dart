import 'package:intl/intl.dart';

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
  final double group1;
  final double group2;
  final double group3;

  AttendanceData({
    required this.date,
    required this.group1,
    required this.group2,
    required this.group3,
  });

  // Get total percentage
  double get total => group1 + group2 + group3;

  // Get percentage for a specific group
  double getGroupPercentage(int groupId) {
    switch (groupId) {
      case 1:
        return group1;
      case 2:
        return group2;
      case 3:
        return group3;
      default:
        return 0.0;
    }
  }

  // Format date for display
  String get formattedDate {
    try {
      if (date.contains('-')) {
        // Weekly date range format
        return date;
      } else {
        // Daily date format
        final DateTime dateTime = DateFormat('dd\nMMM').parse(date);
        return DateFormat('dd\nMMM').format(dateTime);
      }
    } catch (e) {
      return date;
    }
  }

  factory AttendanceData.fromGroupCounts(
    String date,
    Map<int, int> groupCounts,
  ) {
    int total = groupCounts.values.fold(0, (sum, count) => sum + count);

    return AttendanceData(
      date: date,
      group1: total > 0 ? (groupCounts[1] ?? 0) * 100 / total : 0,
      group2: total > 0 ? (groupCounts[2] ?? 0) * 100 / total : 0,
      group3: total > 0 ? (groupCounts[3] ?? 0) * 100 / total : 0,
    );
  }

  @override
  String toString() {
    return 'AttendanceData(date: $date, group1: $group1%, group2: $group2%, group3: $group3%)';
  }
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
