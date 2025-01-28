import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationBack extends StatelessWidget {
  final Color? iconColor;
  const NavigationBack({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Container(
          width: 30,
          height: 30,
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                width: 3,
                // color: Colors.white
              )),
          child: Center(
              child: Icon(Icons.arrow_back,
                  size: 20, color: iconColor ?? Colors.white))),
    );
  }
}
