import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_engineers/app/modules/home/views/widgets/attendance_card_view.dart';
import 'package:young_engineers/app/modules/home/views/widgets/filter_chip_view.dart';
import 'package:young_engineers/app/modules/utils/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scafffoldColor,
      appBar: AppBar(
        title: const Text(
          'Attendance Analytics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(child: Text('Error: ${controller.error.value}'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChipView(),
                SizedBox(height: 10),
                AttendanceCardView(
                  title: 'Daily attendance',
                  icon: Icons.checklist,
                  data: controller.displayedDailyData,
                  isDaily: true,
                ),
                const SizedBox(height: 8),
                AttendanceCardView(
                  title: 'Weekly attendance',
                  icon: Icons.assignment_turned_in_outlined,
                  data: controller.displayedWeeklyData,
                  isDaily: false,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
