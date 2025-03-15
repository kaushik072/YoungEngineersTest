import 'package:intl/intl.dart';
import 'package:young_engineers/app/modules/utils/api_endpoints.dart';

import '../api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<Map<String, List<AttendanceData>>> getAttendance(
    {Map<String, dynamic>? data}
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getAttendance,
        data: data,
      );

      if (response.data['data'] == null) {
        throw ApiExceptionData('Invalid response format', response.statusCode);
      }

      final List<dynamic> responseData = response.data['data'];
      final records =
          responseData.map((json) => AttendanceRecord.fromJson(json)).toList();

      // Process both daily and weekly in one go
      return {
        'daily': processDailyData(records),
        'weekly': processWeeklyData(records),
      };
    } catch (e) {
      throw ApiExceptionData('Failed to fetch attendance records: $e', null);
    }
  }

  // Future<Map<String, List<AttendanceData>>> getAttendance() async {
  //   try {
  //     final response = await _apiClient.post(ApiEndpoints.getAttendance);

  //     //   data: {

  //     // "groupIds" : [1,2,3]
  //     //   }

  //     if (response.data['data'] == null) {
  //       throw ApiException('Invalid response format', response.statusCode);
  //     }

  //     final List<dynamic> data = response.data['data'];
  //     final records =
  //         data.map((json) => AttendanceModel.fromJson(json)).toList();
  //     return {
  //       'daily': processDailyData(records),
  //       'weekly': processWeeklyData(records),
  //     };
  //   } on ApiException {
  //     rethrow;
  //   } catch (e) {
  //     throw ApiException('Failed to fetch daily attendance: $e', null);
  //   }
  // }
  List<AttendanceData> processDailyData(List<AttendanceRecord> records) {
    // Group records by date
    Map<String, Map<int, int>> dailyGroupCounts = {};

    for (var record in records) {
      if (record.status == 'Present') {
        String formattedDate = record.date; // Already in YYYY-MM-DD format

        // Initialize map for this date if it doesn't exist
        dailyGroupCounts.putIfAbsent(
          formattedDate,
          () => {
            1: 0, // Initialize group 1
            2: 0, // Initialize group 2
            3: 0, // Initialize group 3
          },
        );

        // Increment count for the group
        dailyGroupCounts[formattedDate]![record.groupId] =
            (dailyGroupCounts[formattedDate]![record.groupId] ?? 0) + 1;
      }
    }

    // Convert to AttendanceData objects
    List<AttendanceData> dailyData =
        dailyGroupCounts.entries.map((entry) {
          String date = entry.key;
          Map<int, int> groupCounts = entry.value;

          // Calculate total attendance for the day
          int totalAttendance = groupCounts.values.fold(
            0,
            (sum, count) => sum + count,
          );

          // Calculate percentages
          double group1Percentage =
              totalAttendance > 0
                  ? (groupCounts[1] ?? 0) * 100 / totalAttendance
                  : 0.0;
          double group2Percentage =
              totalAttendance > 0
                  ? (groupCounts[2] ?? 0) * 100 / totalAttendance
                  : 0.0;
          double group3Percentage =
              totalAttendance > 0
                  ? (groupCounts[3] ?? 0) * 100 / totalAttendance
                  : 0.0;

          return AttendanceData(
            date: DateFormat('dd\nMMM').format(DateTime.parse(date)),
            group1: group1Percentage,
            group2: group2Percentage,
            group3: group3Percentage,
          );
        }).toList();

    // Sort by date in descending order
    dailyData.sort((a, b) {
      DateTime dateA = DateFormat('dd\nMMM').parse(a.date);
      DateTime dateB = DateFormat('dd\nMMM').parse(b.date);
      return dateB.compareTo(dateA);
    });

    return dailyData;
  }

  List<AttendanceData> processWeeklyData(List<AttendanceRecord> records) {
    Map<String, Map<int, int>> weeklyGroupCounts = {};

    for (var record in records) {
      if (record.status == 'Present') {
        DateTime recordDate = DateTime.parse(record.date);

        // Get the Monday of the week
        DateTime weekStart = recordDate.subtract(
          Duration(days: recordDate.weekday - 1),
        );
        DateTime weekEnd = weekStart.add(const Duration(days: 6));

        // Create week key with range
        String weekKey =
            '${DateFormat('dd MMM').format(weekStart)}-${DateFormat('dd MMM').format(weekEnd)}';

        // Initialize map for this week if it doesn't exist
        weeklyGroupCounts.putIfAbsent(
          weekKey,
          () => {
            1: 0, // Initialize group 1
            2: 0, // Initialize group 2
            3: 0, // Initialize group 3
          },
        );

        // Increment count for the group
        weeklyGroupCounts[weekKey]![record.groupId] =
            (weeklyGroupCounts[weekKey]![record.groupId] ?? 0) + 1;
      }
    }

    // Convert to AttendanceData objects
    List<AttendanceData> weeklyData =
        weeklyGroupCounts.entries.map((entry) {
          String weekRange = entry.key;
          Map<int, int> groupCounts = entry.value;

          // Calculate total attendance for the week
          int totalAttendance = groupCounts.values.fold(
            0,
            (sum, count) => sum + count,
          );

          // Calculate percentages
          double group1Percentage =
              totalAttendance > 0
                  ? (groupCounts[1] ?? 0) * 100 / totalAttendance
                  : 0.0;
          double group2Percentage =
              totalAttendance > 0
                  ? (groupCounts[2] ?? 0) * 100 / totalAttendance
                  : 0.0;
          double group3Percentage =
              totalAttendance > 0
                  ? (groupCounts[3] ?? 0) * 100 / totalAttendance
                  : 0.0;

          return AttendanceData(
            date: weekRange,
            group1: group1Percentage,
            group2: group2Percentage,
            group3: group3Percentage,
          );
        }).toList();

    // Sort by week start date in descending order
    weeklyData.sort((a, b) {
      String getStartDate(String range) => range.split('-')[0];
      return getStartDate(b.date).compareTo(getStartDate(a.date));
    });

    return weeklyData;
  }
}
