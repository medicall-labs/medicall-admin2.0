import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Screens/Dashboard/insights.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:provider/provider.dart';

import '../../Utils/Widgets/access_denied.dart';

class NonLiveData extends StatefulWidget {
  final String nonLiveEvent;

  NonLiveData({required this.nonLiveEvent});

  @override
  _NonLiveDataState createState() => _NonLiveDataState();
}

class _NonLiveDataState extends State<NonLiveData> {
  final eventDetails = GetStorage().read("event_details") != ''
      ? GetStorage().read("event_details")
      : '';
  var storedData = GetStorage().read("local_store");

  int? selectedEventId;
  String? selectedEventTitle;

  @override
  Widget build(BuildContext context) {
    if (selectedEventId != null) {
      return Insights();
    }

    // Otherwise, show the grid of events
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: widget.nonLiveEvent == 'Completed'
            ? eventDetails['currentAndPreviousEvents'].length - 1
            : eventDetails['currentAndUpcomingEvents'].length - 1,
        itemBuilder: (context, index) {
          var event = widget.nonLiveEvent == 'Completed'
              ? eventDetails['currentAndPreviousEvents'][index + 1]
              : eventDetails['currentAndUpcomingEvents'][index + 1];
          return GestureDetector(
            onTap: (widget.nonLiveEvent == 'Completed' &&
                    storedData['data']['permissions']
                            ['can_view_previous_event'] !=
                        true)
                ? () {
                    showAccessDeniedSnackbar();
                  }
                : () {
                    setState(() {
                      selectedEventId = event['id'];
                      selectedEventTitle = event['title'];
                      Provider.of<LocalDataProvider>(context, listen: false)
                          .changeEventDetails(
                              selectedEventId!, selectedEventTitle!);
                    });
                  },
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: AppColor.white,
                  border: Border.all(
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        event['thumbnail'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        event['title'],
                        style: AppTextStyles.text,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// old code
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:admin_medicall/Providers/local_data.dart';
// import 'package:admin_medicall/Screens/Dashboard/insights.dart';
// import 'package:admin_medicall/Utils/Constants/app_color.dart';
// import 'package:admin_medicall/Utils/Constants/styles.dart';
// import 'package:provider/provider.dart';
//
// class NonLiveData extends StatefulWidget {
//   final String nonLiveEvent;
//
//   NonLiveData({required this.nonLiveEvent});
//
//   @override
//   _NonLiveDataState createState() => _NonLiveDataState();
// }
//
// class _NonLiveDataState extends State<NonLiveData> {
//   final eventDetails = GetStorage().read("eventDetails") != ''
//       ? GetStorage().read("eventDetails")
//       : '';
//
//   int? selectedEventId;
//
//   @override
//   Widget build(BuildContext context) {
//     if (selectedEventId != null) {
//       return Insights(eventId: selectedEventId!);
//     }
//
//     // Otherwise, show the grid of events
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10.0,
//           mainAxisSpacing: 10.0,
//         ),
//         itemCount: widget.nonLiveEvent == 'Completed'
//             ? eventDetails['currentAndPreviousEvents'].length - 1
//             : eventDetails['currentAndUpcomingEvents'].length - 1,
//         itemBuilder: (context, index) {
//           var event = widget.nonLiveEvent == 'Completed'
//               ? eventDetails['currentAndPreviousEvents'][index + 1]
//               : eventDetails['currentAndUpcomingEvents'][index + 1];
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedEventId = event['id']; // Update the selected event ID
//
//                 // Set the selected event ID in LocalDataProvider
//                 Provider.of<LocalDataProvider>(context, listen: false)
//                     .changeEventID(selectedEventId!);
//               });
//             },
//             child: Card(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: AppColor.white,
//                   border: Border.all(
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Image.network(
//                         event['thumbnail'],
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         event['title'],
//                         style: AppTextStyles.text,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// old  old code
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:admin_medicall/Screens/Dashboard/insights.dart';
// import 'package:admin_medicall/Utils/Constants/app_color.dart';
// import 'package:admin_medicall/Utils/Constants/styles.dart';
//
// class NonLiveData extends StatefulWidget {
//   final String nonLiveEvent;
//
//   NonLiveData({required this.nonLiveEvent});
//
//   @override
//   _NonLiveDataState createState() => _NonLiveDataState();
// }
//
// class _NonLiveDataState extends State<NonLiveData> {
//   final eventDetails = GetStorage().read("eventDetails") != ''
//       ? GetStorage().read("eventDetails")
//       : '';
//
//   int? selectedEventId;
//   @override
//   Widget build(BuildContext context) {
//     if (selectedEventId != null) {
//       return Insights(eventId: selectedEventId!);
//     }
//
//     // Otherwise, show the grid of events
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10.0,
//           mainAxisSpacing: 10.0,
//         ),
//         itemCount: widget.nonLiveEvent == 'Completed'
//             ? eventDetails['currentAndPreviousEvents'].length - 1
//             : eventDetails['currentAndUpcomingEvents'].length - 1,
//         itemBuilder: (context, index) {
//           var event = widget.nonLiveEvent == 'Completed'
//               ? eventDetails['currentAndPreviousEvents'][index + 1]
//               : eventDetails['currentAndUpcomingEvents'][index + 1];
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedEventId = event['id']; // Update the selected event ID
//               });
//             },
//             child: Card(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: AppColor.white,
//                   border: Border.all(
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Image.network(
//                         event['thumbnail'],
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         event['title'],
//                         style: AppTextStyles.text,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
