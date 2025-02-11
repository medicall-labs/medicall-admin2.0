import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Utils/Constants/app_color.dart';
import '../../../Utils/Constants/styles.dart';
import '../../../Utils/Widgets/back_button.dart';
import '../items/drag_target_item.dart';
import '../items/line_item.dart';
import '../models/contact_model.dart';
import 'business_card.dart';
import 'form_page.dart';

class ScanPage extends StatefulWidget {
  static const String routeName = 'scan';

  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanOver = false;
  List<String> lines = [];

  String name = '',
      mobile = '',
      email = '',
      address = '',
      company = '',
      designation = '',
      website = '',
      image = '',
      business_type = '';

  void createContact() {
    final contact = ContactModel(
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      image: image,
      business_type: selectedType,
    );
    Get.to(FormPage(
      contactModel: contact,
    ));
  }

  String selectedType = "Select User Type";

  void _showTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(selectedType),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Delegates", "Exhibitor", "Visitor"]
                .map(
                  (type) => ListTile(
                    title: Text(type),
                    onTap: () {
                      setState(() {
                        selectedType = type;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: NavigationBack(),
        ),
        title: Text(
          'Scan the Card',
          style: AppTextStyles.header1,
        ),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera),
                label: Text(
                  'Capture',
                  style: AppTextStyles.text4.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_album),
                label: Text(
                  'Gallery',
                  style: AppTextStyles.text4.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
          if (isScanOver)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DragTargetItem(
                      property: "Name",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Mobile",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Email",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Address",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Company",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Designation",
                      onDrop: getPropertyValue,
                    ),
                    DragTargetItem(
                      property: "Website",
                      onDrop: getPropertyValue,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text('Business Type'),
                        ),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _showTypeSelectionDialog,
                            child: IntrinsicWidth(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedType,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          Wrap(
            children: lines
                .map((line) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: LineItem(line: line),
                    ))
                .toList(),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(AppColor.secondary),
              ),
              onPressed: () => Get.to(BusinessCard()),
              child: Row(
                children: [
                  Text(
                    'Show history',
                    style: AppTextStyles.text4.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.list_alt_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (image.isNotEmpty)
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(AppColor.secondary),
              ),
              onPressed: image.isEmpty ? null : createContact,
              child: Text(
                'View Card Details',
                style: AppTextStyles.text4.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void getImage(ImageSource camera) async {
    final xFile = await ImagePicker().pickImage(
      source: camera,
    );
    if (xFile != null) {
      setState(() {
        image = xFile.path;
      });
      print(xFile.path);
      EasyLoading.show(status: 'Please wait');
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer
          .processImage(InputImage.fromFile(File(xFile.path)));
      EasyLoading.dismiss();

      final tempList = <String>[];

      final labelRegex = RegExp(r'^[A-Za-z\s]+[-]?[A-Za-z\s]+:\s*');

      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          final cleanedLine = line.text.replaceAll(labelRegex, '').trim();

          if (cleanedLine.isNotEmpty) {
            tempList.add(cleanedLine);
          }
        }
      }

      setState(() {
        lines = tempList;
        isScanOver = true;
      });
      print(tempList);
    }
  }

  getPropertyValue(String property, String value) {
    switch (property) {
      case "Name":
        name = value;
        break;
      case "Mobile":
        mobile = value;
        break;
      case "Email":
        email = value;
        break;
      case "Address":
        address = value;
        break;
      case "Company":
        company = value;
        break;
      case "Designation":
        designation = value;
        break;
      case "Website":
        website = value;
        break;
    }
  }
}
