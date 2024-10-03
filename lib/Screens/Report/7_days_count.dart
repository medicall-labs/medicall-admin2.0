import 'package:flutter/material.dart';
import 'package:admin_medicall/Model/data_model.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Widgets/Charts/bar_chart.dart';
import 'package:admin_medicall/Utils/Widgets/back_button.dart';

class Last7DaysCount extends StatefulWidget {
  final String eventTitle;
  final int eventId;

  const Last7DaysCount({
    Key? key,
    required this.eventTitle,
    required this.eventId,
  }) : super(key: key);

  @override
  State<Last7DaysCount> createState() => _Last7DaysCountState();
}

class _Last7DaysCountState extends State<Last7DaysCount> {
  var baseUrl = AppUrl.baseUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NavigationBack(),
        ),
        title: Text(
          widget.eventTitle,
          style: AppTextStyles.header1,
        ),
      ),
      body: FutureBuilder(
        future: RemoteService().getDataFromApi(
            '$baseUrl/admin/events/${widget.eventId}/visitors/last-seven-days'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData &&
              snapshot.data is Map<String, dynamic>) {
            var dashboardData = snapshot.data as Map<String, dynamic>;
            var lastSevenDaysCount = dashboardData['lastSevenDaysCount'] ?? [];

            if (lastSevenDaysCount.isEmpty) {
              return const Center(child: Text('No data available.'));
            }

            List<DataModel> dataModels =
                lastSevenDaysCount.map<DataModel>((item) {
              return DataModel(
                key: item['date'] != null ? item['date'] as String : 'Unknown',
                value: item['count'] != null ? item['count'].toString() : '0',
              );
            }).toList();

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last 7 Days Stats', style: AppTextStyles.header2),
                      AppSpaces.verticalSpace20,
                      BarChartWidget(data: dataModels), // Use BarChartWidget
                      AppSpaces.verticalSpace40,
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColor.secondary.withOpacity(0.2),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  // Center the text horizontally and vertically
                                  child: Text('Date',
                                      style: AppTextStyles.header2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  // Center the text horizontally and vertically
                                  child: Text('Count',
                                      style: AppTextStyles.header2),
                                ),
                              ),
                            ],
                          ),
                          ...lastSevenDaysCount.map((item) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    // Center the text horizontally and vertically
                                    child: Text('${item['date']}'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    // Center the text horizontally and vertically
                                    child: Text('${item['count']}'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          // Row for total count at the bottom of the table
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColor.secondary.withOpacity(0.2),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  // Center the text horizontally and vertically
                                  child: Text('Total',
                                      style: AppTextStyles.header2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  // Center the text horizontally and vertically
                                  child: Text(
                                      '${dashboardData['total'].toString()}',
                                      style: AppTextStyles.header2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
