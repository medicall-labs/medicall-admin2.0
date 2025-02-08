import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Screens/bottom_nav_bar.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import '../Providers/local_data.dart';
import '../Sevices/api_services.dart';
import '../Utils/Constants/api_collection.dart';
import 'Auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  var userDetails = GetStorage().read("login_data") ?? '';
  final requestBaseUrl = AppUrl.baseUrl;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    _loadEventDetails();
  }

  void _loadEventDetails() async {
    var currentEvent = GetStorage().read("local_store");
    if (currentEvent != null) {
      var profileResponse = await RemoteService()
          .getDataFromApi('${requestBaseUrl}/event-details');

      // Save the event details to local storage
      GetStorage().write("event_details", profileResponse);

      Provider.of<LocalDataProvider>(context, listen: false).changeEventDetails(
          profileResponse['currentEventId'],
          profileResponse['currentAndPreviousEvents'][0]['title']);

    }
    _startNavigationTimer(currentEvent);
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          update();
        }
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void update() async {
    print('Updating');
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      SystemNavigator.pop();
    }
  }

  void _startNavigationTimer(var currentEvent) {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          Get.offAll(currentEvent == null ? LoginPage() : BottomNavBar());
        });
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/Logo.png",
          width: 200,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
