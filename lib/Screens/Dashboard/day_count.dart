import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Widgets/back_button.dart';

class DayWiseCount extends StatelessWidget {
  final String date;
  final Map dayData;
  DayWiseCount({super.key, required this.date, required this.dayData});

  @override
  Widget build(BuildContext context) {
    List heads = dayData.keys.toList();
    DateTime parsedDate = DateTime.parse(date);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: NavigationBack(),
        ),
        title: Text(
          'Insights on ${DateFormat('dd-MM-yyyy').format(parsedDate)}',
          style: AppTextStyles.header1,
        ),
      ),
      backgroundColor: AppColor.bgColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: heads.length,
          itemBuilder: (context, index) {
            String category = heads[index];
            Map categoryData = dayData[category];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Row(
                      children: [
                        Text(category.toUpperCase(), style: AppTextStyles.text.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),),
                        AppSpaces.horizontalSpace10,
                        Image.asset(
                          _getCategoryImage(category),
                          height: 40,
                          width: 40,
                        ),
                      ],
                    ),

                    // Data rows
                    _buildDataRow('Total Registered:',
                        categoryData['total_register_count'].toString()),
                    const SizedBox(height: 5),
                    _buildDataRow('Visited Count:',
                        categoryData['visited_count'].toString()),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for displaying data row
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.text2,
        ),
        Text(value, style: AppTextStyles.label2),
      ],
    );
  }

  // Helper function to get category-specific images
  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'online':
        return 'assets/images/online.png';
      case 'spot':
        return 'assets/images/spot.png';
      case 'whatsapp':
        return 'assets/images/whatsapp.png';
      case '10t':
        return 'assets/images/10t.png';
      case 'delegates':
        return 'assets/images/delegate.png';
      default:
        return 'assets/images/default.png'; // Fallback for unknown categories
    }
  }
}
