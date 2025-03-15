import 'package:young_engineers/app/data/models/attendance_model.dart';

class ChartData {
  final String date;
  final double group1;
  final double group2;
  final double group3;
  final double total;

  ChartData({
    required this.date,
    required this.group1,
    required this.group2,
    required this.group3,
    required this.total,
  });

  factory ChartData.fromAttendanceData(AttendanceData data) {
    return ChartData(
      date: data.formattedDate,
      group1: data.group1,
      group2: data.group2,
      group3: data.group3,
      total: data.total,
    );
  }
}
