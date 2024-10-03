import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:admin_medicall/Model/data_model.dart';

class BarChartWidget extends StatefulWidget {
  final List<DataModel> data;

  const BarChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  _BarChartWidgetState createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  late List<DataModel> currentData;

  @override
  void initState() {
    super.initState();
    currentData = widget.data; // Initialize with the provided data
  }

  @override
  void didUpdateWidget(covariant BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      // Trigger animation if the data changes
      currentData = widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentData.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    // Determine the maximum Y value for dynamic scaling
    double maxY = currentData
        .map((item) => double.tryParse(item.value ?? '0') ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Ensure maxY is at least 1 to avoid zero interval
    maxY = maxY > 0 ? maxY : 1;

    return Container(
      height: 300, // Reduced height of the bar chart
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: BarChart(
          key: ValueKey<List<DataModel>>(currentData), // Key for animation
          BarChartData(
            maxY: maxY + 10, // Add margin above the max value
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String weekDay = currentData[group.x.toInt()].key ?? 'Unknown';
                  return BarTooltipItem(
                    '$weekDay\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: rod.toY.toString(),
                        style: TextStyle(
                          color: rod.gradient?.colors.first ?? rod.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            barGroups: _chartGroups(maxY),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.7), // Visible bottom border
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.grey.withOpacity(0.7), // Visible left border
                  width: 1,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 5), // Dynamic intervals for Y axis lines
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.5),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Text(
                          currentData[value.toInt()].key ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (maxY / 5) > 0 ? (maxY / 5) : 1, // Ensure interval is greater than zero
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
            ),
          ),
        ),
      ),
    );
  }

  // Chart Groups
  List<BarChartGroupData> _chartGroups(double maxY) {
    return List.generate(currentData.length, (index) {
      final active = double.tryParse(currentData[index].value ?? '0') ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: active,
            width: 14,
            gradient: const LinearGradient(
              colors: [Colors.greenAccent, Colors.blueAccent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
          ),
        ],
      );
    });
  }
}
