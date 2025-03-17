import 'package:young_engineers/app/data/models/attendance_model.dart';

class ChartData {
  final String date;
  final List<BarData> bars;

  ChartData({required this.date, required this.bars});

  factory ChartData.fromAttendanceData(AttendanceData data) {
    return ChartData(
      date: data.formattedDate,
      bars:
          data.groupData.values
              .map(
                (groupData) => BarData(
                  value: groupData.percentage,
                  color: groupData.color,
                  groupId: groupData.groupId,
                ),
              )
              .toList(),
    );
  }
}
