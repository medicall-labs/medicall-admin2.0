import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart'; // GetStorage import
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAnnouncements(); // Load announcements from storage when app starts
  }

  // Load announcements from GetStorage
  void _loadAnnouncements() {
    List<dynamic>? storedData = storage.read('announcements');
    if (storedData != null) {
      setState(() {
        // Cast to List<dynamic> and then convert each item to Map<String, String>
        announcements = List<Map<String, String>>.from(
          storedData.map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  // Save announcements to GetStorage
  void _saveAnnouncements() {
    storage.write('announcements', announcements);
  }

  // Show Add Announcement Dialog
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
                      maxLines: 3,
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
                  if (selectedImage != null) {
                    // Upload image to Firebase
                    imageUrl = await _uploadImageToFirebase(selectedImage!);
                  }

                  if (imageUrl.isNotEmpty || selectedImage == null) { // Check if image URL is valid
                    // Construct the request body
                    final body = {
                      'title': title,
                      'event_id': 'your_event_id_here', // Replace with your event ID
                      'description': description,
                      'visible_type': selectedVisibility,
                      'is_active': false,
                    };

                    // Send the announcement
                    await _sendAnnouncement(body);

                    setState(() {
                      announcements.add({
                        'title': title,
                        'description': description,
                        'imagePath': imageUrl, // Save the image URL
                      });
                      selectedImage = null; // Clear image after processing
                    });
                    _saveAnnouncements(); // Save announcements to GetStorage
                    Navigator.pop(context); // Close preview dialog
                    Navigator.pop(context); // Close create announcement dialog
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

// Function to send announcement
  Future<void> _sendAnnouncement(Map<String, dynamic> body) async {
    final String token = 'your_token_here'; // Replace with your token logic
    final url = Uri.parse('https://crm.medicall.in/api/admin/store-announcements');

    // try {
    //   // final response = await http.post(
    //   //   url,
    //   //   headers: {
    //   //     'Authorization': 'Bearer $token',
    //   //     'Content-Type': 'application/json',
    //   //     'Accept': '*/*',
    //   //   },
    //   //   body: jsonEncode(body), // Encode the body to JSON
    //   // );
    //
    //   // if (response.statusCode == 200) {
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     const SnackBar(content: Text('Announcement sent successfully!')),
    //   //   );
    //   // } else {
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     const SnackBar(content: Text('Error sending announcement.')),
    //   //   );
    //   }
    // } catch (e) {
    //   print('Error: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Error sending announcement.')),
    //   );
    // }
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

  // Show the selected announcement details
  void _showAnnouncementDetails(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(announcements[index]['title']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              announcements[index]['imagePath']!.isNotEmpty
                  ? Image.network(
                      announcements[index]['imagePath']!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image),
              const SizedBox(height: 10),
              Text(
                announcements[index]['description']!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Delete an announcement and save the updated list to GetStorage
  void _deleteAnnouncement(int index) {
    setState(() {
      announcements.removeAt(index);
    });
    _saveAnnouncements();
  }


  @override
  Widget build(BuildContext context) {
    final localDataProvider = Provider.of<LocalDataProvider>(context);
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
      body: announcements.isEmpty
          ? const Center(
              child: Text(
                'No announcements yet.',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(announcements[index]['title']!),
                  subtitle: Text(announcements[index]['description']!),
                  leading: announcements[index]['imagePath']!.isNotEmpty
                      ? Image.network(
                          announcements[index]['imagePath']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  onTap: () => _showAnnouncementDetails(index),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteAnnouncement(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// image sent to firebase and url received
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:get_storage/get_storage.dart'; // GetStorage import
// import 'package:admin_medicall/Providers/local_data.dart';
// import 'package:admin_medicall/Utils/Constants/app_color.dart';
// import 'package:admin_medicall/Utils/Constants/styles.dart';
// import 'package:provider/provider.dart';
//
// class Announcements extends StatefulWidget {
//   const Announcements({super.key});
//
//   @override
//   State<Announcements> createState() => _AnnouncementsState();
// }
//
// class _AnnouncementsState extends State<Announcements> {
//   List<Map<String, String>> announcements = [];
//   File? selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final storage = GetStorage(); // Initialize GetStorage
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAnnouncements(); // Load announcements from storage when app starts
//   }
//
//   // Load announcements from GetStorage
//   void _loadAnnouncements() {
//     List<dynamic>? storedData = storage.read('announcements');
//     if (storedData != null) {
//       setState(() {
//         // Cast to List<dynamic> and then convert each item to Map<String, String>
//         announcements = List<Map<String, String>>.from(
//           storedData.map((item) => Map<String, String>.from(item)),
//         );
//       });
//     }
//   }
//
//   // Save announcements to GetStorage
//   void _saveAnnouncements() {
//     storage.write('announcements', announcements);
//   }
//
//   // Show Add Announcement Dialog
//   void _showAddAnnouncementDialog() {
//     String title = '';
//     String description = '';
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text('Create Announcement'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       onChanged: (value) => title = value,
//                       decoration: const InputDecoration(
//                         labelText: 'Title',
//                         hintText: 'Enter title',
//                       ),
//                     ),
//                     TextField(
//                       onChanged: (value) => description = value,
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                         hintText: 'Enter description',
//                       ),
//                       maxLines: 3,
//                     ),
//                     const SizedBox(height: 10),
//                     selectedImage == null
//                         ? ElevatedButton(
//                       onPressed: () async {
//                         final XFile? image = await _picker.pickImage(
//                             source: ImageSource.gallery);
//                         if (image != null) {
//                           setState(() {
//                             selectedImage = File(image.path);
//                           });
//                         }
//                       },
//                       child: const Text('Select Image'),
//                     )
//                         : Column(
//                       children: [
//                         Image.file(
//                           selectedImage!,
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             setState(() {
//                               selectedImage = null;
//                             });
//                           },
//                           child: const Text('Remove Image'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (title.isNotEmpty && description.isNotEmpty) {
//                       _showPreviewAnnouncementDialog(title, description);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Title and description are mandatory'),
//                         ),
//                       );
//                     }
//                   },
//                   child: const Text('Preview'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showPreviewAnnouncementDialog(String title, String description) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Preview Announcement'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (selectedImage != null)
//                 Image.file(
//                   selectedImage!,
//                   width: 100,
//                   height: 100,
//                   fit: BoxFit.cover,
//                 ),
//               const SizedBox(height: 10),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 5),
//               Text(description, style: const TextStyle(fontSize: 16)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Edit'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // If there is a selected image, upload it
//                 if (selectedImage != null) {
//                   // Upload image to Firebase
//                   String imageUrl = await _uploadImageToFirebase(selectedImage!);
//
//                   if (imageUrl.isNotEmpty) { // Check if image URL is valid
//                     setState(() {
//                       announcements.add({
//                         'title': title,
//                         'description': description,
//                         'imagePath': imageUrl, // Save the image URL
//                       });
//                       selectedImage = null; // Clear image after processing
//                     });
//                     _saveAnnouncements(); // Save announcements to GetStorage
//                     Navigator.pop(context); // Close preview dialog
//                     Navigator.pop(context); // Close create announcement dialog
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Error uploading image.')),
//                     );
//                   }
//                 } else {
//                   // If no image is selected, save the announcement with a blank imagePath
//                   setState(() {
//                     announcements.add({
//                       'title': title,
//                       'description': description,
//                       'imagePath': '', // Save a blank string for imagePath
//                     });
//                     selectedImage = null; // Clear image after processing
//                   });
//                   _saveAnnouncements(); // Save announcements to GetStorage
//                   Navigator.pop(context); // Close preview dialog
//                   Navigator.pop(context); // Close create announcement dialog
//                 }
//               },
//               child: const Text('Send'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Function to upload image to Firebase Storage and return the URL
//   Future<String> _uploadImageToFirebase(File image) async {
//     try {
//       // Create a unique file name
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       // Reference to the Firebase Storage
//       Reference ref =
//       FirebaseStorage.instance.ref().child('announcements/$fileName');
//
//       // Uploading the file
//       await ref.putFile(image);
//       // Getting the download URL
//       String downloadUrl = await ref.getDownloadURL();
//       return downloadUrl; // Return the URL
//     } catch (e) {
//       print('Error uploading image: $e');
//       return ''; // Return an empty string or handle the error appropriately
//     }
//   }
//
//   // Show the selected announcement details
//   void _showAnnouncementDetails(int index) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(announcements[index]['title']!),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               announcements[index]['imagePath']!.isNotEmpty
//                   ? Image.network(
//                 announcements[index]['imagePath']!,
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//               )
//                   : const Icon(Icons.image),
//               const SizedBox(height: 10),
//               Text(
//                 announcements[index]['description']!,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Delete an announcement and save the updated list to GetStorage
//   void _deleteAnnouncement(int index) {
//     setState(() {
//       announcements.removeAt(index);
//     });
//     _saveAnnouncements();
//   }
//
//   // Simulate sending the announcement (can be extended to actually send)
//   void _sendAnnouncement(int index) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           content:
//           Text("Announcement '${announcements[index]['title']}' sent!")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localDataProvider = Provider.of<LocalDataProvider>(context);
//     final String eventTitle = localDataProvider.eventTitle;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColor.secondary,
//         automaticallyImplyLeading: false,
//         title: Text(
//           eventTitle,
//           style: AppTextStyles.header1,
//         ),
//       ),
//       backgroundColor: AppColor.bgColor,
//       body: announcements.isEmpty
//           ? const Center(
//         child: Text(
//           'No announcements yet.',
//           style: TextStyle(fontSize: 20),
//         ),
//       )
//           : ListView.builder(
//         itemCount: announcements.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(announcements[index]['title']!),
//             subtitle: Text(announcements[index]['description']!),
//             leading: announcements[index]['imagePath']!.isNotEmpty
//                 ? Image.network(
//               announcements[index]['imagePath']!,
//               width: 50,
//               height: 50,
//               fit: BoxFit.cover,
//             )
//                 : const Icon(Icons.image),
//             onTap: () => _showAnnouncementDetails(index),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 _deleteAnnouncement(index);
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddAnnouncementDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
