import 'dart:io';

import 'package:apha_journal/screens/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override 
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com',
  );
  final ImagePicker _picker = ImagePicker();

  String? _imageUrl; // Holds the URL of the selected image

  // Controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool _isAgeSaved = false; // Flag to track if the age has been saved

  // Function to fetch user data from Firestore
Future<void> _fetchUserData() async {
  DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
  if (userDoc.exists) {
    final data = userDoc.data() as Map<String, dynamic>?;

    setState(() {
      usernameController.text = data?.containsKey('username') == true ? data!['username'] as String? ?? 'Empty' : 'Empty';
      birthDateController.text = data?.containsKey('birth of date') == true ? data!['birth of date'] as String? ?? 'Empty' : 'Empty';
      professionController.text = data?.containsKey('profession') == true ? data!['profession'] as String? ?? 'Empty' : 'Empty';
      bioController.text = data?.containsKey('bio') == true ? data!['bio'] as String? ?? 'Empty' : 'Empty';
      ageController.text = data?.containsKey('age') == true ? data!['age']?.toString() ?? '' : '';
      _imageUrl = data?.containsKey('profileImageUrl') == true ? data!['profileImageUrl'] as String? : null;
      _isAgeSaved = data?.containsKey('age') == true;
    });
  }
}


  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      String downloadURL = await _uploadImage(File(pickedImage.path));
      if (downloadURL.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update({'profileImageUrl': downloadURL});
        setState(() {
          _imageUrl = downloadURL;
        });
      }
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
    if (field == 'age' && _isAgeSaved) {
      _showAgeEditNotAllowedDialog();
      return;
    }

    String? newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Edit $field', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: field == 'age' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            if (field == 'age') 
              const Text(
                'Make sure your age entered is correct and cannot be changed',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser.uid).update({field: newValue});
      setState(() {
        controller.text = newValue;
        if (field == 'age') {
          _isAgeSaved = true;
        }
      });
    }
  }

  void _showAgeEditNotAllowedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Edit Age', style: TextStyle(color: Colors.white)),
          content: const Text(
            'You are not allowed to edit your age after it is saved.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
  title: const Text('Profile Page', style: TextStyle(color: Colors.white)),
  backgroundColor: const Color.fromARGB(255, 193, 110, 110),
  leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
    ),
  
),



      body: ListView(
        padding: const EdgeInsets.all(16.0),
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
                    backgroundColor: Colors.grey[700],
                    child: const Icon(Icons.add_a_photo, color: Colors.white),
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 50),
          Text(
            'My Details',
            style: TextStyle(color: Colors.grey[600], fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          _buildDetailTile('Username:', usernameController),
          const SizedBox(height: 10),
          _buildDetailTile('Birth of date:', birthDateController),
          const SizedBox(height: 10),
          _buildDetailTile('Profession:', professionController),
          const SizedBox(height: 10),
          _buildDetailTile('Bio:', bioController),
          const SizedBox(height: 10),
          _buildDetailTile('Age:', ageController, ageBox: true),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String title, TextEditingController controller, {bool ageBox = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        border: ageBox && controller.text.isEmpty
            ? Border.all(color: Colors.red, width: 2.0)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => editField(title.replaceFirst(':', '').trim().toLowerCase(), controller),
        ),
        title: Text(
          controller.text.isEmpty ? 'No Data' : controller.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Function to show image dialog
  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Profile Picture', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(_imageUrl!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImage();
                    },
                    child: const Text('Change Picture', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _viewImage();
                    },
                    child: const Text('View Full Image', style: TextStyle(color: Colors.white)),
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
            color: Colors.black,
            width: double.infinity,
            height: 400,
            child: _imageUrl != null
              ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Text('No Image Available', style: TextStyle(color: Colors.white)),
                ),
          ),
        );
      },
    );
  }
}
