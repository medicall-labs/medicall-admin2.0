import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';

class DismissibleCardList extends StatefulWidget {
  final Map data;

  DismissibleCardList({super.key, required this.data});

  @override
  _DismissibleCardListState createState() => _DismissibleCardListState();
}

class _DismissibleCardListState extends State<DismissibleCardList> {
  int currentIndex = 0;

  final Map<String, Map<String, dynamic>> categoryImages = {
    'online': {'path': 'assets/images/online.png', 'width': 40.0, 'height': 40.0},
    'spot': {'path': 'assets/images/spot.png', 'width': 40.0, 'height': 40.0},
    'whatsapp': {'path': 'assets/images/whatsapp.png', 'width': 45.0, 'height': 45.0},
    '10t': {'path': 'assets/images/10t.png', 'width': 55.0, 'height': 55.0},
    'delegates': {'path': 'assets/images/delegate.png', 'width': 50.0, 'height': 50.0},
  };

  void _onDismissed() {
    setState(() {
      currentIndex++;
      if (currentIndex >= widget.data.keys.length) {
        currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = widget.data.keys.toList();
    if (dates.isEmpty) return Container(); // Return empty if no data

    final currentDate = dates[currentIndex];

    String formatDate(String date) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    }

    return Container(
      // height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Dismissible(
        key: Key(currentDate),
        onDismissed: (direction) {
          _onDismissed();
        },
        background: Container(color: Colors.red),
        secondaryBackground: Container(color: Colors.blue),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(currentDate),
                style: AppTextStyles.text4.copyWith(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    widget.data[currentDate]!.keys.map<Widget>((category) {
                  var counts = widget.data[currentDate]![category]!;
                  var imageData = categoryImages[category] ??
                      {'path': 'assets/images/Logo.png', 'width': 50.0, 'height': 50.0};

                  return Column(
                    children: [
                      Container(
                        height: 60,
                        child: SizedBox(
                          width: imageData['width'],
                          height: imageData['height'],
                          child: Image.asset(
                            imageData['path'],
                            fit: BoxFit.contain, // Ensures image fits within the box
                          ),
                        ),
                      ),
                      Text(
                        '${counts['visited_count']}',
                        style: TextStyle(color: AppColor.primary, fontSize: 16),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
