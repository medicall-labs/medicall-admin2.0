import 'dart:convert';
import 'dart:io';

import 'package:admin_medicall/Screens/Dashboard/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../Sevices/api_services.dart';
import '../../../Utils/Constants/app_color.dart';
import '../../../Utils/Constants/styles.dart';
import '../../../Utils/Widgets/back_button.dart';
import '../../bottom_nav_bar.dart';
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
  final business_typeController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    designationController.text = widget.contactModel.designation;
    websiteController.text = widget.contactModel.website;
    business_typeController.text = widget.contactModel.business_type;

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
            TextFormField(
              controller: business_typeController,
              decoration: const InputDecoration(labelText: 'Business Type'),
              validator: (value) {
                return null;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(AppColor.secondary),
          ),
          onPressed: saveContact,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Submit Card',
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
      widget.contactModel.business_type = business_typeController.text;

      print('5400==========>>>>>>>>>>>>>'
          '\n ${widget.contactModel.name} \n'
          '\n ${widget.contactModel.mobile} \n'
          '\n ${widget.contactModel.email} \n'
          '\n ${widget.contactModel.address} \n'
          '\n ${widget.contactModel.designation} \n'
          '\n ${widget.contactModel.website} \n'
          '\n ${widget.contactModel.business_type} \n');

      _submitForm();
    }
  }

  void _submitForm() async {

    String imageUrl = '';
    _showLoadingDialog(context);

      imageUrl = await _uploadImageToFirebase(File(widget.contactModel.image));

    Map<String, String> data = {
      'name': nameController.text,
      'mobile': mobileController.text,
      'email': emailController.text,
      'address': addressController.text,
      'company': companyController.text,
      'designation': designationController.text,
      'website': websiteController.text,
      'type': business_typeController.text,
      'image_path': imageUrl
    };

    try {
      var response = await RemoteService().postDataToApi(
          'https://crm.medicall.in/api/admin/business-card/store', data);
      var result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Business card information stored successfully!')),
        );
        Get.offAll(() => BottomNavBar());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error sending Business card details. \n Please try again')),
        );
        Get.offAll(() => BottomNavBar());
      }
    } catch (err) {
      print("$err");
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Disable back button press
          child: Dialog(
            backgroundColor:
            Colors.transparent, // Make the background transparent
            elevation: 0,
            child: Center(
              child: CircularProgressIndicator(), // Show a loading spinner
            ),
          ),
        );
      },
    );
  }

  // Function to upload image to Firebase Storage and return the URL
  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Create a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // Reference to the Firebase Storage
      Reference ref =
      FirebaseStorage.instance.ref().child('/business_card/$fileName');

      // Uploading the file
      await ref.putFile(image);
      // Getting the download URL
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl; // Return the URL
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string or handle the error appropriately
    }
  }

}
