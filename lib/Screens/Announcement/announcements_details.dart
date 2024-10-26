import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../Utils/Constants/app_color.dart';
import '../../Utils/Constants/styles.dart';
import '../../Utils/Widgets/back_button.dart';

class AnnouncementsDetails extends StatefulWidget {
  final String title;
  final description;
  final image;
  AnnouncementsDetails(
      {super.key,
      required this.title,
      required this.description,
      required this.image});

  @override
  State<AnnouncementsDetails> createState() => _AnnouncementsDetailsState();
}

class _AnnouncementsDetailsState extends State<AnnouncementsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NavigationBack(),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.header1,
        ),
      ),
      body: Card(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColor.white,
              border: Border.all(
                width: 1,
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image != null && widget.image!.isNotEmpty)
                Center(
                    child: Container(
                        height: 200,
                        padding: EdgeInsets.only(top: 10),
                        child: Image.network(widget.image))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 5,
                padding: const EdgeInsets.all(8.0),
                child: Html(
                  data: widget.description ?? 'No Description',
                  style: {
                    "img": Style(
                        width: Width(MediaQuery.of(context).size.width * 0.6),
                        height:
                            Height(MediaQuery.of(context).size.width * 0.6)),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
