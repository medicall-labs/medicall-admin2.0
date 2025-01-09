import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';

class DayCard extends StatelessWidget {
  final String day;
  final String date;
  final int registered;
  final int visited;
  final Color progressColor;

  DayCard({
    required this.day,
    required this.date,
    required this.registered,
    required this.visited,
    required this.progressColor,
  });

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              day,
              style: AppTextStyles.text3.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            AppSpaces.verticalSpace5,
            Text(
              formatDate(date),
              style: AppTextStyles.text4.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            AppSpaces.verticalSpace5,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Registered: ',
                    style: AppTextStyles.text3.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: registered.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Circular Progress Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 8,
                      color: AppColor.grey.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          registered != 0
                              ? (visited / registered) * 100 <= 100
                                  ? '${((visited / registered) * 100).toStringAsFixed(2)}%'
                                  : '100%'
                              : '0%',
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: registered != 0 ? (visited / registered) : 0,
                      ),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, _) => SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 8,
                          value: value,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
           AppSpaces.verticalSpace5,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Visited : ',
                    style: AppTextStyles.text3.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: visited.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
