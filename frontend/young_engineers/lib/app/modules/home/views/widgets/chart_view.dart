import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:young_engineers/app/data/models/attendance_model.dart';

class ChartView extends StatelessWidget {
  final RxList<AttendanceData> data;
  final bool isHorizontal;
  const ChartView({super.key, required this.data, required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      isTransposed: isHorizontal,
      plotAreaBorderColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        interval: 1,
        labelRotation: 0,
        majorTickLines: const MajorTickLines(size: 5, width: 1),
        edgeLabelPlacement: EdgeLabelPlacement.none,
        arrangeByIndex: false,
        labelStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
        axisLine: const AxisLine(color: Colors.blueAccent),
        majorGridLines: const MajorGridLines(color: Colors.transparent),
        autoScrollingDelta: 6,
        autoScrollingMode: AutoScrollingMode.end,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        zoomMode: ZoomMode.xy,
      ),
      primaryYAxis: NumericAxis(
        majorTickLines: const MajorTickLines(size: 5, width: 1),
        opposedPosition: isHorizontal ? false : true,
        axisLine: const AxisLine(width: 0),
        minimum: 10,
        maximum: 100,
        interval: 10,
        majorGridLines: MajorGridLines(
          color: Colors.grey.shade200,
          width: 1,
          dashArray: const <double>[5, 5],
        ),
        labelFormat: '{value}%',
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      series: <CartesianSeries>[
        ...data.isNotEmpty ? _generateGroupSeries(data) : [],

        ScatterSeries<AttendanceData, String>(
          dataSource: data,
          xValueMapper: (AttendanceData data, _) => data.date,
          yValueMapper: (AttendanceData data, _) => data.totalPercentage,

          markerSettings: MarkerSettings(
            isVisible: false,
            width: 0,
          ), // Hide marker
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            margin: EdgeInsets.only(bottom: isHorizontal ? 0 : 5),
            labelAlignment: ChartDataLabelAlignment.top,
            labelPosition: ChartDataLabelPosition.outside,

            builder: (
              dynamic data,
              dynamic point,
              dynamic series,
              int pointIndex,
              int seriesIndex,
            ) {
              // double total = data.total;
              return Text(
                '${(data as AttendanceData).totalPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ).paddingOnly(bottom: 10);
            },
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        builder: (
          dynamic data,
          dynamic point,
          dynamic series,
          int pointIndex,
          int seriesIndex,
        ) {
          final AttendanceData attendanceData = data as AttendanceData;
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${attendanceData.formattedDate}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                ...attendanceData.groupData.entries.map((entry) {
                  final groupData = entry.value;
                  return Text(
                    'Group ${groupData.groupId}: ${groupData.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: groupData.color),
                  );
                }),
                const Divider(color: Colors.white30),
                Text(
                  'Total: ${attendanceData.totalPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<StackedBarSeries<AttendanceData, String>> _generateGroupSeries(
    List<AttendanceData> data,
  ) {
    Set<int> groupIds = {};
    for (var item in data) {
      groupIds.addAll(item.groupData.keys);
    }
    List<int> sortedGroupIds = groupIds.toList()..sort();

    return sortedGroupIds.map((groupId) {
      bool isFirst = groupId == sortedGroupIds.first;
      bool isLast = groupId == sortedGroupIds.last;

      return StackedBarSeries<AttendanceData, String>(
        dataSource: data,
        xValueMapper: (AttendanceData data, _) => data.formattedDate,
        yValueMapper: (AttendanceData data, _) {
          // Calculate proportional percentage within total
          double totalPercentage = data.totalPercentage;
          double groupPercentage = data.groupData[groupId]?.percentage ?? 0;
          int totalGroups = data.groupData.length;

          // Distribute the group's share within total percentage
          return totalPercentage > 0
              ? (groupPercentage / totalGroups) * (totalPercentage / 100)
              : 0;
        },
        name: 'Group $groupId',
        width: isHorizontal ? 0.3 : 0.5,
        spacing: 0.2,
        borderRadius:
            !isHorizontal
                ? BorderRadius.only(
                  topRight: Radius.circular(isLast ? 3 : 0),
                  bottomRight: Radius.circular(isLast ? 3 : 0),
                )
                : BorderRadius.only(
                  topLeft: Radius.circular(isLast ? 3 : 0),
                  topRight: Radius.circular(isLast ? 3 : 0),
                ),
        color: data.first.groupData[groupId]?.color ?? Colors.grey,
      );
    }).toList();
  }
}
