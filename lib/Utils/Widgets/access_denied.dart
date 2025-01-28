import 'package:get/get.dart';
import 'package:flutter/material.dart';

void showAccessDeniedSnackbar() {
  Get.snackbar(
    'Access Denied',
    'You do not have permission to access this page.',
    backgroundColor: Colors.white,
    colorText: Colors.black,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(10),
  );
}
