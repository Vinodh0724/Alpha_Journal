import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apha_journal/screens/home/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override 
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com', // Add your Firebase Storage bucket URL here
  );
  final ImagePicker _picker = ImagePicker();

  String? _imageUrl; // Holds the URL of the selected image

  // Controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists) {
      setState(() {
        usernameController.text = userDoc['username'] ?? 'Empty';
        birthDateController.text = userDoc['birthDate'] ?? 'Empty';
        professionController.text = userDoc['profession'] ?? 'Empty';
        bioController.text = userDoc['bio'] ?? 'Empty';
        // Retrieve and set the profile image URL
        _imageUrl = userDoc['profileImageUrl'];
      });
    }
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      String downloadURL = await _uploadImage(File(pickedImage.path));
      setState(() {
        _imageUrl = downloadURL;
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      Reference ref = _storage.ref().child('user_profile_images/${currentUser.uid}');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Function to edit field
  Future<void> editField(String field, TextEditingController controller) async {
    String newValue = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser.uid).update({field: newValue});
      setState(() {
        controller.text = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Center(
            child: GestureDetector(
              onTap: () {
                if (_imageUrl != null) {
                  _showImageDialog();
                } else {
                  _pickImage();
                }
              },
              child: _imageUrl != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_imageUrl!),
                  )
                : CircleAvatar(
                    radius: 60,
                    child: Icon(Icons.add_a_photo),
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'My Details',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          MyTextBox(
            text: usernameController.text,
            sectionName: 'Username',
            onPressed: () => editField('username', usernameController),
          ),
          MyTextBox(
            text: birthDateController.text,
            sectionName: 'Birth of date',
            onPressed: () => editField('birthDate', birthDateController),
          ),
          MyTextBox(
            text: professionController.text,
            sectionName: 'Profession',
            onPressed: () => editField('profession', professionController),
          ),
          MyTextBox(
            text: bioController.text,
            sectionName: 'Bio',
            onPressed: () => editField('bio', bioController),
          ),
        ],
      ),
    );
  }

  // Function to show image dialog
  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(_imageUrl!),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImage();
                    },
                    child: Text('Change Picture'),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _viewImage();
                    },
                    child: Text('View Full Image'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to view full image
  void _viewImage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 400,
            child: _imageUrl != null
              ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Text('No Image Available'),
                ),
          ),
        );
      },
    );
  }
} //hfhfhfhfhfh
