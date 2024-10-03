import 'package:flutter/material.dart';

void showMessage({
  required BuildContext context,
  String? mainMessage,
  String? secondaryMessage,
  String? tertiaryMessage,
  Color? backgroundColor,
}) {
  final snackBarContent = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (mainMessage != null) Text(mainMessage, style: TextStyle(color: Colors.white)),
      if (secondaryMessage != null) Text(secondaryMessage, style: TextStyle(color: Colors.white)),
      if (tertiaryMessage != null) Text(tertiaryMessage, style: TextStyle(color: Colors.white)),
    ],
  );

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: snackBarContent,
    backgroundColor: backgroundColor,
    duration: Duration(seconds: 3),
  ));
}
