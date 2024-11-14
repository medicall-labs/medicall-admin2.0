import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../Utils/Constants/api_collection.dart';

class RemoteService {
  var baseUrl = AppUrl.baseUrl;
  var tokenDetails = GetStorage().read("local_store") != ''
      ? GetStorage().read("local_store")
      : '';

  getPublicDataFromApi(apiPath) async {
    try {
      final uri = Uri.parse(apiPath);
      var response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(const Duration(minutes: 1));
      return compute(parseUserData, response.body);
    } on TimeoutException {
      return {
        'success': false,
        'status': 'Request timed out',
        'message': 'TimeOut'
      };
    } on SocketException {
      return {
        'success': false,
        'status': 'You are offline',
        'message': 'Offline'
      };
    } catch (err) {
      print("$err");
      return "Please try again later";
    }
  }

  getDataFromApi(apiPath) async {
    try {
      final uri = Uri.parse(apiPath);
      var response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${tokenDetails["token"]}',
      }).timeout(const Duration(minutes: 1));
      return compute(parseUserData, response.body);
    } on TimeoutException {
      return {
        'success': false,
        'status': 'Request timed out',
        'message': 'TimeOut'
      };
    } on SocketException {
      return {
        'success': false,
        'status': 'You are offline',
        'message': 'Offline'
      };
    } catch (err) {
      print("$err");
      return "Please try again later";
    }
  }

  parseUserData(String responseBody) {
    var jsonData = jsonDecode(responseBody);
    return jsonData;
  }

  postDataToApi(apiPath, apiBody) async {
    try {
      final uri = Uri.parse(apiPath);
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenDetails["token"]}',
          },
          body: jsonEncode(apiBody));
      return response;
    } catch (err) {
      print("$err");
      return "Please try again later";
    }
  }
}
