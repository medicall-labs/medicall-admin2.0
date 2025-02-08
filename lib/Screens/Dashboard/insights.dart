import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Screens/Dashboard/day_count.dart';
import 'package:admin_medicall/Screens/Dashboard/dismissible_card.dart';
import 'package:admin_medicall/Screens/Dashboard/info_card.dart';
import 'package:admin_medicall/Screens/Dashboard/day_card.dart';
import 'package:admin_medicall/Screens/Dashboard/show_appointment.dart';
import 'package:admin_medicall/Screens/bottom_nav_bar.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:provider/provider.dart';

import '../../Utils/Widgets/access_denied.dart';

class Insights extends StatefulWidget {
  Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  var baseUrl = AppUrl.baseUrl;
  var storedData = GetStorage().read("local_store");

  int calculateTotalRegisteredCount(Map<String, dynamic> dayData) {
    int total = 0;
    dayData.forEach((key, value) {
      total += (value['total_register_count'] as int?) ?? 0;
    });
    return total;
  }

  int calculateTotalVisitedCount(Map<String, dynamic> dayData) {
    int total = 0;
    dayData.forEach((key, value) {
      total += (value['visited_count'] as int?) ?? 0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final localDataProvider = Provider.of<LocalDataProvider>(context);
    final eventId = localDataProvider.eventId;

    var eventDetails = GetStorage().read("event_details") != ''
        ? GetStorage().read("event_details")
        : '';

    return SingleChildScrollView(
      child: FutureBuilder(
        future: RemoteService()
            .getDataFromApi('$baseUrl/admin/dashboard?event_id=$eventId'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var dashboardData = snapshot.data;
            if (dashboardData != null &&
                dashboardData is Map<String, dynamic>) {
              var data = dashboardData;
              var eventVisitorData = data['event_visitor_data'];
              if (eventVisitorData != null &&
                  eventVisitorData is Map<String, dynamic>) {
                List<String> days = eventVisitorData.keys.toList();
                List<Map<String, dynamic>> values =
                    List<Map<String, dynamic>>.from(eventVisitorData.values);
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            if (eventDetails['currentEventId'] != eventId)
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.offAll(eventDetails['currentEventId'] >=
                                            eventId
                                        ? BottomNavBar(current_tab: 1)
                                        : BottomNavBar(current_tab: 2));
                                  },
                                  child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            width: 2,
                                          )),
                                      child: const Center(
                                          child: Icon(Icons.arrow_back,
                                              size: 20, color: Colors.grey))),
                                ),
                              ),
                            Text(
                              data['title'],
                              style: AppTextStyles.header2,
                            ),
                          ],
                        ),
                      ),
                      AppSpaces.verticalSpace5,
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InfoCard(
                              title: 'Exhibitors',
                              icon: Icons.business,
                              count: data['exhibitors_count'] ?? 0,
                            ),
                            InfoCard(
                              title: 'Visitors',
                              icon: Icons.people,
                              count: data['visitors_count'] ?? 0,
                            ),
                            InfoCard(
                              title: 'Delegates',
                              icon: Icons.person,
                              count: data['delegateCount'] ?? 0,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < days.length; i++)
                              GestureDetector(
                                onTap: () {
                                  Get.to(DayWiseCount(
                                    date: days[i].toString(),
                                    dayData: data['event_visitor_data']
                                        [days[i]],
                                  ));
                                },
                                child: DayCard(
                                  day: 'Day ${i + 1}',
                                  date: days[i].toString(),
                                  registered:
                                      calculateTotalRegisteredCount(values[i]),
                                  visited:
                                      calculateTotalVisitedCount(values[i]),
                                  progressColor: i == 0
                                      ? Colors.blue
                                      : (i == 1
                                          ? AppColor.primary
                                          : Colors.green),
                                ),
                              ),
                          ],
                        ),
                      ),
                      DismissibleCardList(
                        data: eventVisitorData,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'Appointment',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Total Appointments',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['total_appointments_count']
                                          .toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'scheduled',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Scheduled count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['scheduled_count'].toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'rescheduled',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Rescheduled count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['rescheduled_count'].toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'no-show',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'No Show count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['lapsed_count'].toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'cancelled',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Cancelled count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['cancelled_count'].toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'completed',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Completed count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['completed_count'].toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: storedData['data']['permissions']
                                          ['can_view_appointment'] ==
                                      true
                                  ? () {
                                      Get.to(ShowAppointment(
                                        heading: 'Appointment',
                                      ));
                                    }
                                  : () {
                                      showAccessDeniedSnackbar();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ListTile(
                                  title: Text(
                                    'Booked Visitor Count',
                                    style: AppTextStyles.text4,
                                  ),
                                  trailing: Text(
                                      data['visitorAppointmentCount']
                                          .toString(),
                                      style: AppTextStyles.text),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                    child: Text('No event visitor data available.'));
              }
            } else {
              return const Center(child: Text('No data available.'));
            }
          }
        },
      ),
    );
  }
}

// old code
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:admin_medicall/Screens/Dashboard/dismissible_card.dart';
// import 'package:admin_medicall/Screens/Dashboard/info_card.dart';
// import 'package:admin_medicall/Screens/Dashboard/day_card.dart';
// import 'package:admin_medicall/Screens/bottom_nav_bar.dart';
// import 'package:admin_medicall/Sevices/api_services.dart';
// import 'package:admin_medicall/Utils/Constants/api_collection.dart';
// import 'package:admin_medicall/Utils/Constants/app_color.dart';
// import 'package:admin_medicall/Utils/Constants/spacing.dart';
// import 'package:admin_medicall/Utils/Constants/styles.dart';
//
// class Insights extends StatefulWidget {
//   final int? eventId;
//   Insights({super.key, this.eventId});
//
//   @override
//   State<Insights> createState() => _InsightsState();
// }
//
// final eventDetails = GetStorage().read("eventDetails") != ''
//     ? GetStorage().read("eventDetails")
//     : '';
//
// class _InsightsState extends State<Insights> {
//   var baseUrl = AppUrl.baseUrl;
//
//   int calculateTotalRegisteredCount(Map<String, dynamic> dayData) {
//     int total = 0;
//     if (dayData != null) {
//       dayData.forEach((key, value) {
//         total += (value['total_register_count'] as int?) ?? 0;
//       });
//     }
//     return total;
//   }
//
//   int calculateTotalVisitedCount(Map<String, dynamic> dayData) {
//     int total = 0;
//     if (dayData != null) {
//       dayData.forEach((key, value) {
//         total += (value['visited_count'] as int?) ?? 0;
//       });
//     }
//     return total;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: FutureBuilder(
//         future: RemoteService().getDataFromApi(
//             '$baseUrl/admin/dashboard?event_id=${widget.eventId}'),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else {
//             var dashboardData = snapshot.data;
//             if (dashboardData != null &&
//                 dashboardData is Map<String, dynamic>) {
//               var data = dashboardData;
//               var eventVisitorData = data['event_visitor_data'];
//               if (eventVisitorData != null &&
//                   eventVisitorData is Map<String, dynamic>) {
//                 List<String> days = eventVisitorData.keys.toList();
//                 List<Map<String, dynamic>> values =
//                     List<Map<String, dynamic>>.from(eventVisitorData.values);
//                 return SizedBox(
//                   width: double.infinity,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5),
//                         child: Row(
//                           children: [
//                             if (eventDetails['currentEventId'] !=
//                                 widget.eventId)
//                               Padding(
//                                 padding: EdgeInsets.only(left: 5, right: 10.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Get.offAll(eventDetails['currentEventId'] >=
//                                             widget.eventId
//                                         ? BottomNavBar(current_tab: 1)
//                                         : BottomNavBar(current_tab: 2));
//                                   },
//                                   child: Container(
//                                       width: 30,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           border: Border.all(
//                                             width: 2,
//                                           )),
//                                       child: const Center(
//                                           child: Icon(Icons.arrow_back,
//                                               size: 20, color: Colors.grey))),
//                                 ),
//                               ),
//                             Text(
//                               data['title'],
//                               style: AppTextStyles.header2,
//                             ),
//                           ],
//                         ),
//                       ),
//                       AppSpaces.verticalSpace5,
//                       Container(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(10))),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             InfoCard(
//                               title: 'Exhibitors',
//                               icon: Icons.person,
//                               count: data['exhibitors_count'] ?? 0,
//                             ),
//                             InfoCard(
//                               title: 'Visitors',
//                               icon: Icons.person,
//                               count: data['visitors_count'] ?? 0,
//                             ),
//                             InfoCard(
//                               title: 'Delegates',
//                               icon: Icons.person,
//                               count: data['delegates_count'] ?? 0,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             for (int i = 0; i < days.length; i++)
//                               DayCard(
//                                 day: 'Day ${i + 1}',
//                                 date: days[i].toString(),
//                                 registered:
//                                     calculateTotalRegisteredCount(values[i]),
//                                 visited: calculateTotalVisitedCount(values[i]),
//                                 progressColor: i == 0
//                                     ? Colors.blue
//                                     : (i == 1
//                                         ? AppColor.primary
//                                         : Colors.green),
//                               ),
//                           ],
//                         ),
//                       ),
//                       DismissibleCardList(
//                         data: eventVisitorData,
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 10.0, right: 10, bottom: 10),
//                         child: Column(
//                           children: <Widget>[
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Total Appointments'),
//                                 trailing: Text(data['total_appointments_count']
//                                     .toString()),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Scheduled count'),
//                                 trailing:
//                                     Text(data['scheduled_count'].toString()),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Rescheduled count'),
//                                 trailing:
//                                     Text(data['rescheduled_count'].toString()),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Lapsed count'),
//                                 trailing: Text(data['lapsed_count'].toString()),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Cancelled count'),
//                                 trailing:
//                                     Text(data['cancelled_count'].toString()),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.symmetric(vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: ListTile(
//                                 title: Text('Completed count'),
//                                 trailing:
//                                     Text(data['completed_count'].toString()),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               } else {
//                 return const Center(
//                     child: Text('No event visitor data available.'));
//               }
//             } else {
//               return const Center(child: Text('No data available.'));
//             }
//           }
//         },
//       ),
//     );
//   }
// }
