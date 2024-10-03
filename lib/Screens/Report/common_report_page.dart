import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Widgets/Charts/line_chart.dart';
import 'package:admin_medicall/Utils/Widgets/back_button.dart';

class CommonReportPage extends StatefulWidget {
  final String eventTitle;
  final int eventId;
  final String pageTitle;
  final String endPoint;
  final String tableHeading;

  CommonReportPage({
    super.key,
    required this.eventTitle,
    required this.eventId,
    required this.pageTitle,
    required this.endPoint,
    required this.tableHeading,
  });

  @override
  State<CommonReportPage> createState() => _CommonReportPageState();
}

class _CommonReportPageState extends State<CommonReportPage> {
  var baseUrl = AppUrl.baseUrl;

  bool search = false;
  String searchApi = '';

  // Method to extract data based on the table heading
  List<Map<String, dynamic>> _extractData(Map<String, dynamic> reportData) {
    if (widget.tableHeading == 'City') {
      var locations = reportData['top5Locations'] ?? [];
      return List<Map<String, dynamic>>.from(locations.map((location) {
        return {
          'city': location['city'] ?? 'Unknown',
          'total': location['total'] ?? 0,
          'today_count': location['today_count'] ?? 0,
        };
      }));
    } else if (widget.tableHeading == 'State') {
      var locations = reportData['top5Locations'] ?? [];
      return List<Map<String, dynamic>>.from(locations.map((location) {
        return {
          'state': location['state'] ?? 'Unknown',
          'total': location['total'] ?? 0,
          'today_count': location['today_count'] ?? 0,
        };
      }));
    } else if (widget.tableHeading == 'Country') {
      var locations = reportData['top5Locations'] ?? [];
      return List<Map<String, dynamic>>.from(locations.map((location) {
        return {
          'country': location['country'] ?? 'Unknown',
          'total': location['total'] ?? 0,
          'today_count': location['today_count'] ?? 0,
        };
      }));
    } else if (widget.tableHeading == 'Registration Type') {
      return List<Map<String, dynamic>>.from(
          reportData['registrationTypes'] ?? []);
    } else if (widget.tableHeading == 'Profile') {
      return List<Map<String, dynamic>>.from(reportData['businessTypes'] ?? []);
    } else if (widget.tableHeading == 'Known Source') {
      return List<Map<String, dynamic>>.from(reportData['knownSources'] ?? []);
    }
    return [];
  }

  // Method to get column titles based on the type
  List<String> _getColumnTitles() {
    if (widget.tableHeading == 'City') {
      return ['City', 'Visitor', 'Today'];
    } else if (widget.tableHeading == 'State') {
      return ['State', 'Visitor', 'Today'];
    } else if (widget.tableHeading == 'Country') {
      return ['Country', 'Visitor', 'Today'];
    } else if (widget.tableHeading == 'Registration Type') {
      return ['Type', 'Total', 'Today'];
    } else if (widget.tableHeading == 'Profile') {
      return ['Profile', 'Visitor', 'Today'];
    } else if (widget.tableHeading == 'Known Source') {
      return ['Known Source', 'Visitor', 'Today'];
    }
    return [];
  }

  Future<Map<String, dynamic>?> _fetchData() async {
    if (!search) {
      return await RemoteService().getDataFromApi(
        '$baseUrl/admin/events/${widget.eventId}/visitors/${widget.endPoint}',
      );
    } else {
      return await RemoteService().getDataFromApi(searchApi);
    }
  }

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
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData &&
              snapshot.data is Map<String, dynamic>) {
            print('5400 ---- ${snapshot.data}');
            var reportData = snapshot.data as Map<String, dynamic>;
            var chartTableData = _extractData(reportData);

            if (chartTableData.isEmpty) {
              return const Center(child: Text('No data available.'));
            }

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.pageTitle, style: AppTextStyles.header2),
                          Visibility(
                              visible: search,
                              child: IconButton(
                                tooltip: 'Remove Filter',
                                onPressed: () {
                                  search = !search;
                                  setState(() {});
                                },
                                icon: Icon(Icons.filter_alt_off_rounded),
                              )),
                          Visibility(
                            visible: !search,
                            child: IconButton(
                              tooltip: 'Filter by date',
                              onPressed: () async {
                                var fromDate, toDate;
                                final TextEditingController fromController =
                                    TextEditingController();
                                final TextEditingController toController =
                                    TextEditingController();

                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Filter by Date'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            TextField(
                                              controller: fromController,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                labelText: 'From Date',
                                                suffixIcon:
                                                    Icon(Icons.calendar_today),
                                              ),
                                              onTap: () async {
                                                fromDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (fromDate != null) {
                                                  fromController.text =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(fromDate!);
                                                  print(
                                                      'Selected From Date: ${fromController.text}'); // Debugging
                                                }
                                              },
                                            ),
                                            TextField(
                                              controller: toController,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                labelText: 'To Date',
                                                suffixIcon:
                                                    Icon(Icons.calendar_today),
                                              ),
                                              onTap: () async {
                                                toDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (toDate != null) {
                                                  toController.text =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(toDate!);
                                                  print(
                                                      'Selected To Date: ${toController.text}'); // Debugging
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Submit'),
                                          onPressed: () {
                                            if (fromDate != null &&
                                                toDate != null) {
                                              print(
                                                  'Returning Dates: ${fromController.text}, ${toController.text}'); // Debugging
                                              Navigator.of(context).pop([
                                                fromController.text,
                                                toController.text
                                              ]);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: const Text(
                                                      'Please select both dates'),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                fromDate = fromController.text; // From date
                                toDate = toController.text; // To date
                                String apiUrl;
                                if (widget.tableHeading == 'City' ||
                                    widget.tableHeading == 'State' ||
                                    widget.tableHeading == 'Country') {
                                  apiUrl =
                                      '$baseUrl/admin/events/${widget.eventId}/visitors/${widget.endPoint}&startDate=$fromDate&endDate=$toDate';
                                } else {
                                  apiUrl =
                                      '$baseUrl/admin/events/${widget.eventId}/visitors/${widget.endPoint}?startDate=$fromDate&endDate=$toDate';
                                }

                                setState(() {
                                  searchApi = apiUrl.toString();
                                  search = !search;
                                });
                              },
                              icon: const Icon(Icons.filter_alt_rounded),
                            ),
                          ),
                        ],
                      ),
                      AppSpaces.verticalSpace10,
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColor.secondary.withOpacity(0.2),
                            ),
                            children: _getColumnTitles().map((title) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child:
                                      Text(title, style: AppTextStyles.header2),
                                ),
                              );
                            }).toList(),
                          ),
                          ...chartTableData.map((item) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      widget.tableHeading == 'Registration Type'
                                          ? item['name'] ?? 'Unknown'
                                          : widget.tableHeading == 'Profile'
                                              ? item['name'] ?? 'Unknown'
                                              : widget.tableHeading ==
                                                      'Known Source'
                                                  ? item['known_source'] ??
                                                      'Unknown'
                                                  : widget.tableHeading ==
                                                          'State'
                                                      ? item['state'] ??
                                                          'Unknown'
                                                      : widget.tableHeading ==
                                                              'City'
                                                          ? item['city'] ??
                                                              'Unknown'
                                                          : widget.tableHeading ==
                                                                  'Country'
                                                              ? item['country'] ??
                                                                  'Unknown'
                                                              : item['name'] ??
                                                                  'N/A',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text('${item['total'] ?? 0}'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text('${item['today_count'] ?? 0}'),
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
                                  child: Text('Total',
                                      style: AppTextStyles.header2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${reportData['overAllCount']?.toString() ?? 0}',
                                    style: AppTextStyles.header2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${reportData['overAllTodayCount']?.toString() ?? 0}',
                                    style: AppTextStyles.header2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppSpaces.verticalSpace20,
                      SizedBox(
                        child: VisitorDataChart(
                            data: chartTableData, title: widget.tableHeading),
                      ),
                      AppSpaces.verticalSpace10,
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
