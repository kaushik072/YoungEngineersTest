import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
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
        majorTickLines: MajorTickLines(size: 5, width: 1),
        edgeLabelPlacement: EdgeLabelPlacement.none, // Adjust labels properly
        arrangeByIndex: false,
        labelStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
        axisLine: AxisLine(color: Colors.blueAccent),
        majorGridLines: MajorGridLines(color: Colors.transparent),
        autoScrollingDelta: 6,
        autoScrollingMode: AutoScrollingMode.end,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true, // Allow manual panning
        zoomMode: ZoomMode.xy, // Scroll only in X direction
      ),
      primaryYAxis: NumericAxis(
        majorTickLines: MajorTickLines(size: 5, width: 1),
        opposedPosition: isHorizontal ? false : true,
        axisLine: AxisLine(width: 0),
        minimum: 10,
        maximum: 110,
        interval: 10,
        majorGridLines: MajorGridLines(
          color: Colors.lightBlue.shade100, // Change grid line color
          width: 1,
          dashArray: <double>[5, 5], // Optional: Dashed lines
        ),
        labelFormat: '{value}%',
        labelStyle: TextStyle(
          color: Colors.blueAccent, // Y-axis label color
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),

      series: <CartesianSeries>[
        StackedBarSeries<AttendanceData, String>(
          dataSource: data,
          xValueMapper: (AttendanceData data, _) => data.date,
          yValueMapper: (AttendanceData data, _) => data.group1,
          name: 'Group 1',
          width: isHorizontal ? 0.25 : 0.4,
          spacing: 0.2,
          borderRadius:
              isHorizontal
                  ? BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  )
                  : BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
          gradient: LinearGradient(
            begin: isHorizontal ? Alignment.bottomCenter : Alignment.centerLeft,
            end: isHorizontal ? Alignment.topCenter : Alignment.centerRight,
            colors: [Colors.blue, Colors.cyan, Colors.lightBlue.shade200],
          ),
        ),
        StackedBarSeries<AttendanceData, String>(
          dataSource: data,
          xValueMapper: (AttendanceData data, _) => data.date,
          yValueMapper: (AttendanceData data, _) => data.group2,
          name: 'Group 2',
          width: isHorizontal ? 0.25 : 0.4,
          spacing: 0.2,
          gradient: LinearGradient(
            begin: isHorizontal ? Alignment.bottomCenter : Alignment.centerLeft,
            end: isHorizontal ? Alignment.topCenter : Alignment.centerRight,
            colors: [
              Colors.red.shade800,
              Colors.red.shade700,
              Colors.red.shade500,
            ],
          ),
        ),
        StackedBarSeries<AttendanceData, String>(
          dataSource: data,
          xValueMapper: (AttendanceData data, _) => data.date,
          yValueMapper: (AttendanceData data, _) => data.group3,
          name: 'Group 3',
          width: isHorizontal ? 0.25 : 0.4,
          spacing: 0.2,
          borderRadius:
              isHorizontal
                  ? BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  )
                  : BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
          gradient: LinearGradient(
            begin: isHorizontal ? Alignment.bottomCenter : Alignment.centerLeft,
            end: isHorizontal ? Alignment.topCenter : Alignment.centerRight,
            colors: [
              Colors.lightGreen.shade900,
              Colors.lightGreen.shade800,
              Colors.lightGreen.shade400,
            ],
          ),
        ),
        ScatterSeries<AttendanceData, String>(
          dataSource: data,
          xValueMapper: (AttendanceData data, _) => data.date,
          yValueMapper:
              (AttendanceData data, _) => data.total, // Always at the top

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
              double total = data.total;
              return Text(
                '${total.toInt()}%',
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
      legend: Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}
