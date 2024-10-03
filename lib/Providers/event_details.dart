// import 'package:flutter/cupertino.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:medicall_admin/Providers/local_data.dart';
// import 'package:medicall_admin/Sevices/api_services.dart';
// import 'package:medicall_admin/Utils/Constants/api_collection.dart';
// import 'package:provider/provider.dart';
//
// class EventDetailsProvider extends ChangeNotifier {
//   final requestBaseUrl = AppUrl.baseUrl;
//
//   eventsData(BuildContext context) async {
//     try {
//       var eventDetailsResponse = await RemoteService()
//           .getPublicDataFromApi('${requestBaseUrl}/event-details');
//       if (eventDetailsResponse["status"] == 'success') {
//         GetStorage().write('eventDetails', eventDetailsResponse);
//         // Provider.of<LocalDataProvider>(context, listen: false)
//         //     .changeEventID(eventDetailsResponse['currentEventId']);
//         Provider.of<LocalDataProvider>(context, listen: false)
//             .changeEventDetails(eventDetailsResponse['currentEventId'],
//             eventDetailsResponse['currentAndPreviousEvents'][0]['title']);
//         notifyListeners();
//         return eventDetailsResponse;
//       }
//       return {};
//     } catch (err) {
//       print(err);
//       return {};
//     }
//   }
//
//   announcements() async {
//     try {
//       var announcementsResponse = await RemoteService()
//           .getPublicDataFromApi('${requestBaseUrl}/visitor/announcements');
//       if (announcementsResponse["status"] == 'success') {
//         return announcementsResponse;
//       }
//       return {};
//     } catch (err) {
//       print(err);
//       return {};
//     }
//   }
// }
