import 'dart:io';
import 'package:admin_medicall/Screens/Announcement/announcements_details.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:provider/provider.dart';
import '../../Utils/Constants/api_collection.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  List<Map<String, String>> announcements = [];
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final storage = GetStorage(); // Initialize GetStorage
  var eventDetails;
  late var localDataProvider;
  @override
  void initState() {
    super.initState();
    eventDetails = GetStorage().read("event_details") ?? '';
    localDataProvider = Provider.of<LocalDataProvider>(context, listen: false);
  }

  void _showAddAnnouncementDialog() {
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create Announcement'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) => title = value,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter title',
                      ),
                    ),
                    TextField(
                      onChanged: (value) => description = value,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter description',
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    selectedImage == null
                        ? ElevatedButton(
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                setState(() {
                                  selectedImage = File(image.path);
                                });
                              }
                            },
                            child: const Text('Select Image'),
                          )
                        : Column(
                            children: [
                              Image.file(
                                selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                child: const Text('Remove Image'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (title.isNotEmpty && description.isNotEmpty) {
                      _showPreviewAnnouncementDialog(title, description);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title and description are mandatory'),
                        ),
                      );
                    }
                  },
                  child: const Text('Preview'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPreviewAnnouncementDialog(String title, String description) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preview Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedImage != null)
                Image.file(
                  selectedImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () async {
                // Prompt for visibility type
                String? selectedVisibility = await _showVisibilityTypeDialog();
                if (selectedVisibility != null) {
                  // If there is a selected image, upload it
                  String imageUrl = '';
                  _showLoadingDialog(context);
                  if (selectedImage != null) {
                    // Upload image to Firebase
                    imageUrl = await _uploadImageToFirebase(selectedImage!);
                  }

                  if (imageUrl.isNotEmpty || selectedImage == null) {
                    // Construct the request body
                    final body = {
                      'title': title,
                      'event_id': localDataProvider.eventId,
                      'image': imageUrl,
                      'description': description,
                      'visible_type': selectedVisibility,
                      'is_active': true,
                    };

                    var response = await RemoteService().postDataToApi(
                        'https://crm.medicall.in/api/admin/store-announcements',
                        body);
                    Navigator.pop(context);
                    Navigator.pop(context); // Close preview dialog
                    Navigator.pop(context); // Close create announcement dialog
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Announcement sent successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error sending announcement.')),
                      );
                    }

                    setState(() {
                      announcements.add({
                        'title': title,
                        'description': description,
                        'imagePath': imageUrl,
                      });
                      selectedImage = null;
                    });
                    // _saveAnnouncements(); // Save announcements to GetStorage
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error uploading image.')),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
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
          FirebaseStorage.instance.ref().child('announcements/$fileName');

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

  Future<String?> _showVisibilityTypeDialog() async {
    String? selectedValue;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Visibility Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Visitors Only'),
                onTap: () {
                  selectedValue = 'visitors_only';
                  Navigator.pop(context, selectedValue);
                },
              ),
              ListTile(
                title: const Text('Exhibitors Only'),
                onTap: () {
                  selectedValue = 'exhibitors_only';
                  Navigator.pop(context, selectedValue);
                },
              ),
              ListTile(
                title: const Text('Both'),
                onTap: () {
                  selectedValue = 'both';
                  Navigator.pop(context, selectedValue);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var baseUrl = AppUrl.baseUrl;
    final localDataProvider = Provider.of<LocalDataProvider>(context);
    final int eventId = localDataProvider.eventId;
    final String eventTitle = localDataProvider.eventTitle;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        automaticallyImplyLeading: false,
        title: Text(
          eventTitle.toString(),
          style: AppTextStyles.header1,
        ),
      ),
      backgroundColor: AppColor.bgColor,
      body: FutureBuilder(
        future: RemoteService()
            .getDataFromApi('$baseUrl/admin/announcements?event_id=$eventId'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData &&
              snapshot.data is Map<String, dynamic>) {
            var announcementData = snapshot.data as Map<String, dynamic>;
            var announcements = announcementData['data'] ?? [];
            if (announcements.isEmpty) {
              return const Center(child: Text('No announcements available.'));
            }
            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final event = announcements[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(AnnouncementsDetails(
                        title: event['title'],
                        description: event['description'],
                        image: event['image']));
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (event['image'] != null &&
                              event['image']!.isNotEmpty)
                            Image.network(event['image'],
                                width: 50, height: 50, fit: BoxFit.cover),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(event['title'],
                                  style: AppTextStyles.label3)),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white),
                            child: Text(
                              event['visible_type'] == 'exhibitors_only'
                                  ? 'Exhibitors'
                                  : event['visible_type'] == 'visitors_only'
                                      ? 'Visitors'
                                      : 'Both',
                              style: AppTextStyles.buttomMenuSelected,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No announcements available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
