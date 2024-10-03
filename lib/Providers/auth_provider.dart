import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Screens/Auth/login.dart';
import 'package:admin_medicall/Screens/bottom_nav_bar.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider extends ChangeNotifier {
  final requestBaseUrl = AppUrl.baseUrl;

  ///Setter
  bool _isLoading = false;
  String _resMessage = '';

  var tokenDetails = GetStorage().read("local_store") != ''
      ? GetStorage().read("local_store")
      : '';

  //Getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;

  //Login
  void loginUser({
    required String mobileNumber,
    required String password,
    required bool otp,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    String value;
    if (otp == true) {
      value = "yes";
    } else {
      value = "no";
    }
    final body = {
      "mobile_number": mobileNumber,
      "password": password,
      "is_otp_login": value,
      "type": 'admin'
    };
    try {
      final uri = Uri.parse('$requestBaseUrl/login');
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body));
      var result = jsonDecode(response.body);
      if (result["status"] == "success") {
        GetStorage().write("local_store", result);
        var profileResponse = await RemoteService()
            .getDataFromApi('${requestBaseUrl}/event-details');
        GetStorage().write("event_details", profileResponse);
        _isLoading = false;
        _resMessage = "Login successfull!";
        Provider.of<LocalDataProvider>(context, listen: false)
            .changeEventDetails(profileResponse['currentEventId'],
                profileResponse['currentAndPreviousEvents'][0]['title']);
       notifyListeners();
        Get.offAll(() => BottomNavBar());
      } else {
        _resMessage = result['message'];
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = "Internet connection is not available`";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = "Please try again`";
      notifyListeners();
      print(":::: $e");
    }
  }

  otp(data) async {
    try {
      final uri = Uri.parse('$requestBaseUrl/otp-request');
      var apiBody = {"mobile_number": data, "type": 'visitor'};
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(apiBody));
      return jsonDecode(response.body);
    } catch (err) {
      return null;
    }
  }

  changePassword(oldPwd, newPwd, confirmPwd) async {
    try {
      var data = {
        "current_password": oldPwd,
        "new_password": newPwd,
        "confirm_password": confirmPwd,
        "type": 'visitor'
      };
      var response = await RemoteService()
          .postDataToApi('$requestBaseUrl/change-password', data);

      if (response != null) {
        var result = jsonDecode(response.body);
        if (result["status"] == 'success') {
          GetStorage().erase();
          Get.offAll(() => LoginPage());
          Get.snackbar(
            'Password Reset',
            result["message"],
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Password Reset Failed',
            result["message"],
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (err) {
      print(err);
    }
  }

  logout() async {
    try {
      final uri = Uri.parse('$requestBaseUrl/logout');
      var response = await http.post(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${tokenDetails["token"]}',
      });
      var result = jsonDecode(response.body);
      if (result["status"] == "success") {
        GetStorage().erase();
        Get.offAll(() => LoginPage(
              loggedout: true,
            ));
      }

      return response;
    } catch (err) {
      return null;
    }
  }

  void clear() {
    _resMessage = "";
    // _isLoading = false;
    notifyListeners();
  }
}
