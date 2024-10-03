import 'package:flutter/material.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';


Widget customButton(
    {VoidCallback? tap,
    bool? status = false,
    String? text = '',
    double? buttonHeight,
    Color? backgroundColor,
    Color? borderColor,
    BuildContext? context}) {
  return GestureDetector(
    onTap: status == true ? null : tap,
    child: Card(
      elevation: 5,
      child: Container(
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: status == false ? backgroundColor : Colors.grey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColor.secondary,
          ),
        ),
        width: MediaQuery.of(context!).size.width,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          child: FittedBox(
            child: Text(
              status == false ? text! : 'Please wait...',
              style: AppTextStyles.whiteLabel,
            ),
          ),
        ),
      ),
    ),
  );
}


