import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/repository/attendance_repository.dart';
import '../../../data/models/attendance_model.dart';

class HomeController extends GetxController {
  final AttendanceRepository _repository;
  final RxInt recordCount = 2.obs;
  final RxBool isDailyHorizontal = false.obs;
  final RxBool isWeeklyHorizontal = false.obs;
  final RxList<AttendanceData> allDailyData = <AttendanceData>[].obs;
  final RxList<AttendanceData> displayedDailyData = <AttendanceData>[].obs;
  final RxList<AttendanceData> allWeeklyData = <AttendanceData>[].obs;
  final RxList<AttendanceData> displayedWeeklyData = <AttendanceData>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final RxString selectedGroup = RxString('');
  final RxString selectedPos = RxString('');

  // Constants
  static const int itemsPerPage = 4;

  HomeController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceData();
  }

  String formatDailyDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return DateFormat('dd\nMMM').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Map<String, dynamic> buildPayload() {
    Map<String, dynamic> payload = {};

    if (selectedGroup.value.isNotEmpty) {
      payload['groupIds'] = selectedGroup.value.split(' ').last;
    }

    if (selectedPos.value.isNotEmpty) {
      payload['pos_id'] = selectedPos.value.split(' ').last;
    }

    if (selectedDateRange.value != null) {
      payload['start_date'] = formatDate(selectedDateRange.value!.start);

      payload['end_date'] = formatDate(selectedDateRange.value!.end);
    }

    return payload;
  }

  Future<void> fetchAttendanceData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final payload = buildPayload();
        final allData = await _repository.getAttendance(data: payload);

        // Store daily data
        allDailyData.value = allData['daily'] ?? [];
        displayedDailyData.value = allDailyData.take(itemsPerPage).toList();

        // Store weekly data
        allWeeklyData.value = allData['weekly'] ?? [];
        displayedWeeklyData.value = allWeeklyData.take(itemsPerPage).toList();

        // dailyAttendanceData.value = results[0];
        // weeklyAttendanceData.value = results[1];
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreDailyData() {
    final currentLength = displayedDailyData.length;
    final nextItems =
        allDailyData.skip(currentLength).take(itemsPerPage).toList();
    displayedDailyData.addAll(nextItems);
  }

  void loadMoreWeeklyData() {
    final currentLength = displayedWeeklyData.length;
    final nextItems =
        allWeeklyData.skip(currentLength).take(itemsPerPage).toList();
    displayedWeeklyData.addAll(nextItems);
  }

  bool hasMoreDailyData() {
    return displayedDailyData.length < allDailyData.length;
  }

  bool hasMoreWeeklyData() {
    return displayedWeeklyData.length < allWeeklyData.length;
  }

  void toggleDailyChartOrientation() {
    isDailyHorizontal.value = !isDailyHorizontal.value;
  }

  void toggleWeeklyChartOrientation() {
    isWeeklyHorizontal.value = !isWeeklyHorizontal.value;
  }

  void loadAttendanceData() {
    // dailyAttendanceData.value = [
    //   AttendanceData(date: '05\nNOV 2024', group1: 30, group2: 14, group3: 10),
    //   AttendanceData(date: '06\nNOV 2024', group1: 20, group2: 24, group3: 10),
    //   AttendanceData(date: '07\nNOV 2024', group1: 40, group2: 4, group3: 10),
    //   AttendanceData(date: '08\nNOV 2024', group1: 20, group2: 14, group3: 20),
    // ];
    // dailyAttendanceData.value = List.generate(
    //   4,
    //   (index) => AttendanceData(
    //     date: "0$index\nNOV 2024",
    //     group1: 30,
    //     group2: 14,
    //     group3: 10,
    //   ),
    // );

    // weeklyAttendanceData.value = List.generate(
    //   4,
    //   (index) => AttendanceData(
    //     date: "05-10\nNOV 2024",
    //     group1: 30,
    //     group2: 14,
    //     group3: 10,
    //   ),
    // );
  }
}

// class AttendanceData {
//   final String date;
//   final double group1;
//   final double group2;
//   final double group3;

//   AttendanceData({
//     required this.date,
//     required this.group1,
//     required this.group2,
//     required this.group3,
//   });

//   double get total => group1 + group2 + group3;
// }
