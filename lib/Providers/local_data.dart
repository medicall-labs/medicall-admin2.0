import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LocalDataProvider extends ChangeNotifier {
  late Map<String, dynamic> userDetails;
  late int eventId;
  late String eventTitle; // Add a variable to store event title

  LocalDataProvider() {
    var storedData = GetStorage().read("local_store");
    if (storedData != null && storedData != '') {
      userDetails = storedData;
      eventId = userDetails['current_event_id'] ?? 0;
      eventTitle = userDetails['current_event_title'] ?? ''; // Initialize title
    } else {
      userDetails = {};
      eventId = 0;
      eventTitle = ''; // Initialize to empty if no stored title
    }
  }

  // Update the method to change both event ID and title
  void changeEventDetails(int id, String title) {
    eventId = id;
    eventTitle = title; // Update the title
    print(
        'Ruby ----- $eventId ---- $eventTitle');
    notifyListeners();

    // Save to GetStorage (optional if you want to persist the changes)
    userDetails['current_event_id'] = eventId;
    userDetails['current_event_title'] = eventTitle;
  }
}

