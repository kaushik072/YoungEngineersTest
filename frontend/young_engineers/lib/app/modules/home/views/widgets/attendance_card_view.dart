import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:young_engineers/app/data/models/attendance_model.dart';
import 'package:young_engineers/app/modules/home/controllers/home_controller.dart';
import 'package:young_engineers/app/modules/home/views/widgets/chart_view.dart';
import 'package:young_engineers/app/modules/utils/app_colors.dart';

class AttendanceCardView extends StatelessWidget {
  final String title;
  final IconData icon;
  final RxList<AttendanceData> data;
  final bool isDaily;
  const AttendanceCardView({
    super.key,
    required this.data,
    required this.icon,
    required this.isDaily,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Card(
      elevation: 1,
      surfaceTintColor: AppColors.white,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.swap_horiz,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    if (isDaily) {
                      controller.toggleDailyChartOrientation();
                    } else {
                      controller.toggleWeeklyChartOrientation();
                    }
                  },
                ),
              ],
            ),
            _buildLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                final isHorizontal =
                    isDaily
                        ? controller.isDailyHorizontal.value
                        : controller.isWeeklyHorizontal.value;
                return data.isEmpty
                    ? Center(child: Text("No Data Found!"))
                    : ChartView(data: data, isHorizontal: isHorizontal);
              }),
            ),
            Obx(() {
              final hasMore =
                  isDaily
                      ? controller.hasMoreDailyData()
                      : controller.hasMoreWeeklyData();

              if (!hasMore) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  if (isDaily) {
                    controller.loadMoreDailyData();
                  } else {
                    controller.loadMoreWeeklyData();
                  }
                },
                child: Text(
                  'Show more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    final controller = Get.find<HomeController>();
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (controller.selectedGroup.value == text) {
            controller.selectedGroup.value = '';
          } else {
            controller.selectedGroup.value = text;
          }
          controller.fetchAttendanceData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
            color:
                controller.selectedGroup.value == text
                    ? color.withOpacity(0.2)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [color.withOpacity(0.7), color],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _legendItem('Group 1', Colors.blue.shade500),
        const SizedBox(width: 3),
        _legendItem('Group 2', Colors.red.shade500),
        const SizedBox(width: 3),
        _legendItem('Group 3', Colors.green.shade500),
      ],
    );
  }
}
