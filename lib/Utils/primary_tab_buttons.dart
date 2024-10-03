import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';

class PrimaryTabButton extends StatelessWidget {
  final String buttonText;
  final int itemIndex;
  final ValueNotifier<int> notifier;
  final VoidCallback? onTap; // Changed this to onTap to match your usage
  const PrimaryTabButton({
    super.key,
    this.onTap, // Updated to match the new parameter name
    required this.notifier,
    required this.buttonText,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (BuildContext context, _, __) {
          return ElevatedButton(
            onPressed: () {
              notifier.value = itemIndex;
              if (onTap != null) {
                onTap!(); // Call the onTap callback if it's not null
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                notifier.value == itemIndex
                    ? AppColor.secondary.withOpacity(1)
                    : Colors.white,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(
                    color: notifier.value == itemIndex
                        ? AppColor.secondary
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: notifier.value == itemIndex
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: notifier.value == itemIndex ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}

