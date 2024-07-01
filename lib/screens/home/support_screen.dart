import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dateController = TextEditingController();
  final _supportMessageController = TextEditingController();
  File? _image;

  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com',
  );

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _submitSupportRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String userId = user.uid;
          String userEmail = user.email ?? '';
          String? imageUrl;

          if (_image != null) {
            Reference storageReference = _storage
                .ref()
                .child('support_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
            UploadTask uploadTask = storageReference.putFile(_image!);
            TaskSnapshot taskSnapshot = await uploadTask;
            imageUrl = await taskSnapshot.ref.getDownloadURL();
          }

          // Save data to Firestore
          await _firestore.collection('support_requests').add({
            'user_id': userId,
            'email': userEmail,
            'mobile': _mobileController.text,
            'date': _dateController.text,
            'support_message': _supportMessageController.text,
            'image_url': imageUrl ?? '',
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Support request submitted successfully')),
          );

          // Clear form
          _formKey.currentState!.reset();
          setState(() {
            _image = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user logged in')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit support request: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('ddMMyyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEmailField(),
              SizedBox(height: 16),
              _buildTextField(_mobileController, 'Mobile Number'),
              SizedBox(height: 16),
              _buildDateField(context),
              SizedBox(height: 16),
              _buildTextField(_supportMessageController, 'Support Message'),
              SizedBox(height: 24),
              _buildImageSection(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: getImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 3, 54, 5),
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Upload Evidence Image'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitSupportRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 3, 54, 5),
                  shadowColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Submit Support Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? 'No email found';
    return TextFormField(
      initialValue: email,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      style: TextStyle(color: Colors.black),
      readOnly: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: IgnorePointer(
        child: TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date (ddMMyyyy)',
            labelStyle: TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a date';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return _image == null
        ? Text(
            'No image selected.',
            style: TextStyle(color: Colors.black),
          )
        : Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(_image!),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: _removeImage,
              ),
            ],
          );
  }
}
