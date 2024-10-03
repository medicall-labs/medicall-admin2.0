import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppTextStyles {
  static final TextStyle header = GoogleFonts.lato(
      fontWeight: FontWeight.bold, fontSize: 20.sp, color: AppColor.black);
  static final TextStyle header1 = GoogleFonts.lato(
      fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white);

  static final TextStyle header2 = GoogleFonts.lato(
      fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColor.primary);

  static final TextStyle label = GoogleFonts.lato(
      fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColor.black);

  static final TextStyle label2 = GoogleFonts.lato(
      fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColor.primary);
  static final TextStyle blinkText = GoogleFonts.lato(
      fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColor.primary);
  static final TextStyle blinkText2 = GoogleFonts.lato(
      fontSize: 25.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle label3 = GoogleFonts.lato(
      fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColor.primary);

  static final TextStyle label4 = GoogleFonts.lato(
      fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColor.grey);

  static final TextStyle link = GoogleFonts.lato(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
    decoration: TextDecoration.underline,
  );
  static final TextStyle text = GoogleFonts.lato(
      fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColor.black);

  static final TextStyle text2 =
      GoogleFonts.lato(fontSize: 14.sp, color: AppColor.grey);

  static final TextStyle text3 =
      GoogleFonts.lato(fontSize: 12.sp,fontWeight: FontWeight.bold, color: AppColor.grey);

  static final TextStyle text4 =
      GoogleFonts.lato(fontSize: 14.sp, color: AppColor.black);

  static final TextStyle text5 = GoogleFonts.lato(
      fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle buttomMenu = GoogleFonts.lato(
      fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle buttonSeminar = GoogleFonts.lato(
      fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle buttomMenuSelected = GoogleFonts.lato(
      fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColor.secondary);

  static final TextStyle whiteLabel = GoogleFonts.lato(
      fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle whiteLabel2 = GoogleFonts.lato(
      fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColor.white);

  static final TextStyle validation =
      GoogleFonts.lato(fontSize: 12, color: Colors.red);
}
