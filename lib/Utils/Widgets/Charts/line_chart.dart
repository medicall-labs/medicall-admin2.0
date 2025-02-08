import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Constants/styles.dart';

class VisitorDataChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  VisitorDataChart({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendItem(color: Colors.blue, text: "Total Visitors"),
            SizedBox(width: 10),
            LegendItem(color: Colors.red, text: "Today's Visitors"),
          ],
        ),
        SizedBox(
          height: 360,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      String titleText = title == 'City'
                          ? data[value.toInt()]['city']
                          : title == 'State'
                              ? data[value.toInt()]['state']
                              : title == 'Country'
                                  ? data[value.toInt()]['country']
                                  : title == 'Known Source'
                                      ? data[value.toInt()]['known_source']
                                      : data[value.toInt()]['name'] ?? 'Unknown';

                      return Transform(
                        transform: Matrix4.rotationZ(
                            -0.785398), // Rotate 45 degrees (-π/4 radians)
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0), // Adjust padding to reduce space
                          child: Text(
                            titleText,
                            style: TextStyle(
                                fontSize: 10), // Adjust font size as needed
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Reduce reserved size for left labels
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 4.0), // Reduce padding for left labels
                        child: Text(
                          value.toInt().toString(),
                          style:
                              TextStyle(fontSize: 12), // Adjust font size if needed
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: false), // Hides right axis labels
                ),
                topTitles: AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: false), // Hides top axis labels
                ),
              ),
              borderData: FlBorderData(show: true),
              backgroundColor: Colors.grey.shade50,
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: 0,
              maxY: data
                      .map((item) => item['total']?.toDouble() ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  10,
              lineBarsData: [
                // Line for Total Visitors
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    return FlSpot(index.toDouble(), item['total']?.toDouble() ?? 0);
                  }).toList(),
                  isCurved: false,
                  color: Colors.blue, // Line color for total visitors
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.5),
                        Colors.blue.withOpacity(0.3),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Line for Today's Count
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    return FlSpot(
                        index.toDouble(), item['today_count']?.toDouble() ?? 0);
                  }).toList(),
                  isCurved: true,
                  color: Colors.red, // Line color for today's count
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}