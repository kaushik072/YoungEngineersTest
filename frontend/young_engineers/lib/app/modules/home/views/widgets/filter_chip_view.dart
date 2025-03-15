import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_engineers/app/modules/home/controllers/home_controller.dart';

class FilterChipView extends StatelessWidget {
  const FilterChipView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip('Date', context),
        _buildChip('POS', context),
        _buildChip('Group', context),
        Spacer(),
        _buildChip('Clear Filter', context),
      ],
    );
  }

  Widget _buildChip(String label, context) {
    final controller = Get.find<HomeController>();
    return GestureDetector(
      onTap: () {
        if (label == 'POS') {
          _showPOSMenu(context);
        } else if (label == 'Date') {
          _showDateRangePicker(context);
        } else if (label == 'Group') {
          _showGroupMenu(context);
        } else {
          controller.selectedDateRange.value = null;
          controller.selectedGroup.value = '';
          controller.selectedPos.value = '';
          controller.fetchAttendanceData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: Colors.blue)),
      ),
    );
  }

  void _showPOSMenu(BuildContext context) {
    final controller = Get.find<HomeController>();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height + 200,
      ),
      items: [
        PopupMenuItem(value: 'POS 1', child: Text('POS 1')),
        PopupMenuItem(value: 'POS 2', child: Text('POS 2')),
      ],
    ).then((value) {
      if (value != null) {
        controller.selectedPos.value = value;
        controller.fetchAttendanceData();
      }
    });
  }

  void _showDateRangePicker(BuildContext context) async {
    final controller = Get.find<HomeController>();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025, 12, 31),
      initialDateRange:
          controller.selectedDateRange.value ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDateRange.value = picked;
      controller.fetchAttendanceData();
    }
  }

  void _showGroupMenu(BuildContext context) {
    final controller = Get.find<HomeController>();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height + 200,
      ),
      items: [
        PopupMenuItem(value: 'Group 1', child: Text('Group 1')),
        PopupMenuItem(value: 'Group 2', child: Text('Group 2')),
        PopupMenuItem(value: 'Group 3', child: Text('Group 3')),
      ],
    ).then((value) {
      if (value != null) {
        controller.selectedGroup.value = value;
        controller.fetchAttendanceData();
      }
    });
  }
}
