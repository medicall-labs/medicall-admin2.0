import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_medicall/Screens/Master/exhibitor.dart';
import 'package:admin_medicall/Screens/Master/visitor.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;

  InfoCard({
    required this.title,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(title == 'Exhibitors'
            ? ExhibitorMaster()
            : title == 'Visitors'
                ? VisitorMaster()
                : Container());
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: Icon(
                icon,
                color: AppColor.secondary,
              ),
            ),
            AppSpaces.verticalSpace5,
            Text(
              title,
              style: AppTextStyles.text3,
            ),
            AppSpaces.verticalSpace5,
            Text(
              count.toString(),
              style: AppTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }
}
