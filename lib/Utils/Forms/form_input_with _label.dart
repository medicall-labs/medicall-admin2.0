import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';

class LabelledFormInput extends StatefulWidget {
  final String label;
  final String? value;
  final String keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  const LabelledFormInput({
    super.key,
    required this.keyboardType,
    required this.controller,
    required this.obscureText,
    required this.label,
    this.value,
  });

  @override
  _LabelledFormInputState createState() => _LabelledFormInputState();
}

class _LabelledFormInputState extends State<LabelledFormInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpaces.verticalSpace10,
        Text(widget.label.toUpperCase(),
            textAlign: TextAlign.left,
            style: GoogleFonts.lato(fontSize: 12, color: AppColor.black)),
        TextFormField(
          controller: widget.controller,
          style: AppTextStyles.text,
          onTap: () {},
          keyboardType: widget.keyboardType != "Password"
              ? TextInputType.number
              : TextInputType.text,
          obscureText: _obscureText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 10,
            ),
            suffixIcon: widget.label == "Password"
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      size: 20,
                      _obscureText
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      //size: 15.0,
                      // color: HexColor.fromHex("3C3E49"),
                    ),
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.secondary),
            ),
          ),
        ),
      ],
    );
  }
}
