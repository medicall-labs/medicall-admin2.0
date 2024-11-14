import 'dart:convert';
import 'dart:io';

import 'package:admin_medicall/Screens/Dashboard/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../Utils/Constants/app_color.dart';
import '../../../Utils/Constants/styles.dart';
import '../../../Utils/Widgets/back_button.dart';
import '../models/contact_model.dart';
import '../pages/business_card.dart';
import '../providers/contact_provider.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  final ContactModel contactModel;

  const FormPage({super.key, required this.contactModel});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final designationController = TextEditingController();
  final websiteController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    designationController.text = widget.contactModel.designation;
    websiteController.text = widget.contactModel.website;

    super.initState();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Form Page',
          style: AppTextStyles.header1,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.file(File(widget.contactModel.image))),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field must not be empty';
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field must not be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field must not be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Street Address'),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: designationController,
              decoration: const InputDecoration(labelText: 'Designation'),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: websiteController,
              decoration: const InputDecoration(labelText: 'Website'),
              validator: (value) {
                return null;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 150,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(AppColor.secondary),
          ),
          onPressed: saveContact,
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
                Icons.save,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  void saveContact() async {
    if (_formKey.currentState!.validate()) {
      widget.contactModel.name = nameController.text;
      widget.contactModel.mobile = mobileController.text;
      widget.contactModel.email = emailController.text;
      widget.contactModel.address = addressController.text;
      widget.contactModel.company = companyController.text;
      widget.contactModel.designation = designationController.text;
      widget.contactModel.website = websiteController.text;

      Provider.of<ContactProvider>(context, listen: false)
          .insertContact(widget.contactModel)
          .then((value) async {
        if (value > 0) {
          _submitForm();
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(backgroundColor: Colors.green,content: Text('Saved to Google Sheet!')));
          Get.to(HomePage());
        }
      }).catchError((onError) {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text('Failed to save!')));
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      const String scriptURL =
          'https://script.google.com/macros/s/AKfycbxl-e9MSzJFkAZt726Z3gzQBTB7o5GSDdhVLox-03YJxcXD8DAVI-EB85txLCCd0-_v/exec';

      // Collect data from the controllers
      Map<String, String> data = {
        'name': nameController.text,
        'mobile': mobileController.text,
        'email': emailController.text,
        'address': addressController.text,
        'company': companyController.text,
        'designation': designationController.text,
        'website': websiteController.text,
      };

      try {
        var response = await http.post(
          Uri.parse(scriptURL),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.green,content: Text('Saved to Google Sheet!')));

      } catch (error) {
        print("Error: $error");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text('Failed to save!')));
      }
    }
  }
}
