import 'package:intl/intl.dart';
import 'package:young_engineers/app/modules/utils/api_endpoints.dart';

import '../api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<Map<String, List<AttendanceData>>> getAttendance({
    Map<String, dynamic>? data,
  }) async {
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
    Map<String, Map<int, Map<String, int>>> dailyData = {};

    // Process each record
    for (var record in records) {
      String date = record.date;
      int groupId = record.groupId;

      // Initialize date entry if not exists
      dailyData.putIfAbsent(date, () => {});
      
      // Initialize group entry if not exists
      dailyData[date]!.putIfAbsent(groupId, () => {
        'total': 0,
        'present': 0,
      });

      // Increment counters
      dailyData[date]![groupId]!['total'] = 
          (dailyData[date]![groupId]!['total'] ?? 0) + 1;
      
      if (record.status == 'Present') {
        dailyData[date]![groupId]!['present'] = 
            (dailyData[date]![groupId]!['present'] ?? 0) + 1;
      }
    }

    // Convert to AttendanceData objects
    List<AttendanceData> result = dailyData.entries.map((dateEntry) {
      String date = dateEntry.key;
      Map<int, Map<String, int>> groupsData = dateEntry.value;

      // Calculate total students and present students for the day
      int totalStudents = 0;
      int totalPresent = 0;

      // Process each group's data
      Map<int, AttendanceGroupData> groupDataMap = {};
      
      groupsData.forEach((groupId, counts) {
        int groupTotal = counts['total'] ?? 0;
        int groupPresent = counts['present'] ?? 0;
        
        totalStudents += groupTotal;
        totalPresent += groupPresent;

        groupDataMap[groupId] = AttendanceGroupData(
          groupId: groupId,
          posId: groupId == 1 ? 1 : 2, // Position ID based on group
          totalStudents: groupTotal,
          presentStudents: groupPresent,
        );
      });

      // Format date for display
      String formattedDate = DateFormat('dd\nMMM').format(DateTime.parse(date));

      return AttendanceData(
        date: formattedDate,
        groupData: groupDataMap,
      );
    }).toList();

    // Sort by date in descending order
    result.sort((a, b) {
      DateTime dateA = DateFormat('dd\nMMM').parse(a.date);
      DateTime dateB = DateFormat('dd\nMMM').parse(b.date);
      return dateB.compareTo(dateA);
    });

    return result;
  }

List<AttendanceData> processWeeklyData(List<AttendanceRecord> records) {
    // Group records by week
    Map<String, Map<int, Map<String, int>>> weeklyData = {};
    Map<String, String> weekRanges = {};

    for (var record in records) {
      DateTime recordDate = DateTime.parse(record.date);
      
      // Find week start (Monday) and end (Sunday)
      DateTime weekStart = recordDate.subtract(
        Duration(days: recordDate.weekday - 1)
      );
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      
      // Create week key and range
      String weekKey = weekStart.toString().substring(0, 10);
      String weekRange = '${DateFormat('dd MMM').format(weekStart)}-${DateFormat('dd MMM').format(weekEnd)}';
      weekRanges[weekKey] = weekRange;

      // Initialize week data if not exists
      weeklyData.putIfAbsent(weekKey, () => {});
      weeklyData[weekKey]!.putIfAbsent(record.groupId, () => {
        'total': 0,
        'present': 0,
      });

      // Update counters
      weeklyData[weekKey]![record.groupId]!['total'] = 
          (weeklyData[weekKey]![record.groupId]!['total'] ?? 0) + 1;
      
      if (record.status == 'Present') {
        weeklyData[weekKey]![record.groupId]!['present'] = 
            (weeklyData[weekKey]![record.groupId]!['present'] ?? 0) + 1;
      }
    }

    // Convert to AttendanceData objects
    List<AttendanceData> result = weeklyData.entries.map((weekEntry) {
      String weekKey = weekEntry.key;
      Map<int, Map<String, int>> groupsData = weekEntry.value;

      // Process each group's data
      Map<int, AttendanceGroupData> groupDataMap = {};
      
      groupsData.forEach((groupId, counts) {
        groupDataMap[groupId] = AttendanceGroupData(
          groupId: groupId,
          posId: groupId == 1 ? 1 : 2,
          totalStudents: counts['total'] ?? 0,
          presentStudents: counts['present'] ?? 0,
        );
      });

      return AttendanceData(
        date: weekRanges[weekKey] ?? weekKey,
        groupData: groupDataMap,
      );
    }).toList();

    // Sort by week start date in descending order
    result.sort((a, b) {
      String getStartDate(String range) => range.split('-')[0];
      return getStartDate(b.date).compareTo(getStartDate(a.date));
    });

    return result;
  }
}
