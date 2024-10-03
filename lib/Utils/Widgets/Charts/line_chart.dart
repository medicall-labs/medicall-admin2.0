import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VisitorDataChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  VisitorDataChart({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30, // Decrease space for titles
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
                    transform: Matrix4.rotationZ(-0.785398), // Rotate 45 degrees (-π/4 radians)
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0), // Adjust padding to reduce space
                      child: Text(
                        titleText,
                        style: TextStyle(fontSize: 10), // Adjust font size as needed
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
                    padding: const EdgeInsets.only(right: 4.0), // Reduce padding for left labels
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12), // Adjust font size if needed
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
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
              isCurved: true,
              color: Colors.blue, // Line color for total visitors
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(
                    0.3), // Fill color below the line for total visitors
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
                color: Colors.red.withOpacity(
                    0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
