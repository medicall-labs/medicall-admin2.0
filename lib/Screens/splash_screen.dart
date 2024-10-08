import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Screens/bottom_nav_bar.dart';

import '../Sevices/api_services.dart';
import '../Utils/Constants/api_collection.dart';
import 'Auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key})
      : super(
          key: key,
        );

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  var UserDetails = GetStorage().read("login_data") != ''
      ? GetStorage().read("login_data")
      : '';
  final requestBaseUrl = AppUrl.baseUrl;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          var currentEvent = GetStorage().read("local_store");
          Get.offAll(currentEvent == null ? LoginPage() : BottomNavBar());
        });
      }
    });
    Timer.periodic(Duration(minutes: 30), (timer) {
      _loadEventDetails();
    });
  }

  void _loadEventDetails() async {
    var profileResponse =
        await RemoteService().getDataFromApi('${requestBaseUrl}/event-details');
    GetStorage().write("event_details", profileResponse);
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
