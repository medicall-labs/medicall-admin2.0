import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:admin_medicall/Screens/Announcement/announcements.dart';
import 'package:admin_medicall/Screens/Dashboard/home_page.dart';
import 'package:admin_medicall/Screens/Report/default_page.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';

class BottomNavBar extends StatefulWidget {
  final int? currentPage;
  final int? current_tab; // Changed to 'current_tab' for consistency

  BottomNavBar({super.key, this.currentPage, this.current_tab});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int currentIndex;
  late int currentTab;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentPage ?? 1;
    currentTab = widget.current_tab ?? 0;

    screens = [
      DefaultPage(),
      HomePage(tabScreen: currentTab),
      Announcements(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentIndex = 1;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: currentIndex == 1 ? AppColor.primary : AppColor.white,
        child: Lottie.asset('assets/lottie/dashboard.json'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        height: 60,
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                  child: Icon(
                    Icons.data_thresholding_rounded,
                    size: 25,
                    color: currentIndex == 0
                        ? AppColor.primary
                        : Colors.grey.shade400,
                  ),
                ),
                Container(
                  height: 10,
                  child: FittedBox(
                    child: Text(
                      'Reports',
                      style: currentIndex == 0
                          ? AppTextStyles.buttomMenu
                          : AppTextStyles.text5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                  child: Icon(
                    Icons.announcement,
                    size: 25,
                    color: currentIndex == 2
                        ? AppColor.primary
                        : Colors.grey.shade400,
                  ),
                ),
                Container(
                  height: 10,
                  child: FittedBox(
                    child: Text(
                      'Announcements',
                      style: currentIndex == 2
                          ? AppTextStyles.buttomMenu
                          : AppTextStyles.text5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: screens[currentIndex],
    );
  }
}
