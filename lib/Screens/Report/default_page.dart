import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Screens/Report/7_days_count.dart';
import 'package:admin_medicall/Screens/Report/common_report_page.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:provider/provider.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eventDetails = GetStorage().read("event_details") != ''
        ? GetStorage().read("event_details")
        : '';

    final localDataProvider = Provider.of<LocalDataProvider>(context);
    final int eventId = localDataProvider.eventId;
    final String eventTitle = localDataProvider.eventTitle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        automaticallyImplyLeading: false,
        title: Text(
          eventTitle,
          style: AppTextStyles.header1,
        ),
      ),
      backgroundColor: AppColor.bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            if(eventDetails['currentEventId'] <= eventId)
            _buildListTile(
              context,
              title: 'Last 7 Days Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen:
                  Last7DaysCount(eventTitle: eventTitle, eventId: eventId),
            ),
            _buildListTile(
              context,
              title: 'Top Cities Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Top Cities Count',
                tableHeading: 'City',
                endPoint: 'top-locations?type=city',
              ),
            ),
            _buildListTile(
              context,
              title: 'Top States Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Top States Count',
                tableHeading: 'State',
                endPoint: 'top-locations?type=state',
              ),
            ),
            _buildListTile(
              context,
              title: 'Top Countries Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Top Countries Count',
                tableHeading: 'Country',
                endPoint: 'top-locations?type=country',
              ),
            ),
            _buildListTile(
              context,
              title: 'Registration Type Wise Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Registration Type Wise Count',
                tableHeading: 'Registration Type',
                endPoint: 'registration-typewise-count',
              ),
            ),
            _buildListTile(
              context,
              title: 'Business Type Wise Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Business Type Wise Count',
                tableHeading: 'Profile',
                endPoint: 'business-typewise-count',
              ),
            ),
            _buildListTile(
              context,
              title: 'Known Source Wise Count',
              eventTitle: eventTitle,
              eventId: eventId,
              destinationScreen: CommonReportPage(
                eventTitle: eventTitle,
                eventId: eventId,
                pageTitle: 'Known Source',
                tableHeading: 'Known Source',
                endPoint: 'knownsource-wise-count',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String eventTitle,
    required String title,
    required int eventId,
    required Widget destinationScreen, // New parameter for destination screen
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.label),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.grey, size: 15),
        onTap: () {
          Get.to(destinationScreen); // Navigate to the specified screen
        },
      ),
    );
  }
}
