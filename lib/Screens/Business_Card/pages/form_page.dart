import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../models/contact_model.dart';
import '../pages/business_card.dart';
import '../providers/contact_provider.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';

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
        title: const Text('Form Page'),
        actions: [
          IconButton(
            onPressed: saveContact,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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

  void saveContact() {
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
          .then((value) {
        if (value > 0) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Saved!')));
          Get.to(BusinessCard());
        }
      }).catchError((onError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save!')));
      });
    }
  }
}
