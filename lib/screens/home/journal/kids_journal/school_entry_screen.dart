import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SchoolEntryScreen extends StatefulWidget {
  final Map<String, String>? templateData;

  const SchoolEntryScreen({Key? key, this.templateData}) : super(key: key);

  @override
  _SchoolEntryScreenState createState() => _SchoolEntryScreenState();
}

class _SchoolEntryScreenState extends State<SchoolEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  List<File> _images = []; 
  bool _isImportant = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com',
  );

  @override
  void initState() {
    super.initState();
    if (widget.templateData != null) {
      _titleController.text = widget.templateData!['title'] ?? '';
      _descriptionController.text = widget.templateData!['description'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _saveEntry() async {
    final User? user = FirebaseAuth.instance.currentUser; // Get userId from the AuthenticationBloc

    if (user != null && _titleController.text.isNotEmpty) {
      String formattedTitle = 'School: ${_titleController.text}';
      List<String> imageUrls = await _uploadImages();
      await _firestore.collection('entries').add({
        'title': formattedTitle,
        'description': _descriptionController.text,
        'reflection': _reflectionController.text,
        'achievements': _achievementsController.text,
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'isImportant': _isImportant,
        'userId': user.uid,// Add userId to the entry
      });
      Navigator.pop(context);
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (File image in _images) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('journal_entries/$fileName');
      await storageRef.putFile(image);
      String downloadUrl = await storageRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Journal Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 156, 54, 54),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 34, 33, 33),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color.fromARGB(255, 43, 255, 0), width: 2),
                      ),
                      child: Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                  ..._images.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color.fromARGB(255, 255, 0, 0), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Color.fromARGB(255, 255, 0, 0)),
                            onPressed: () {
                              setState(() {
                                _images.remove(image);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter your school journal entry title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 255, 0)),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter your school journal entry description',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 255, 8)),
                  ),
                ),
                maxLines: 5,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Reflection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _reflectionController,
                decoration: InputDecoration(
                  hintText: 'Enter your school journal entry reflection',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 255, 8)),
                  ),
                ),
                maxLines: 5,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _achievementsController,
                decoration: InputDecoration(
                  hintText: 'Enter your school journal entry achievements',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 255, 8)),
                  ),
                ),
                maxLines: 5,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.transparent,
                      ),
                      child: Checkbox(
                        checkColor: Colors.green,
                        activeColor: Colors.transparent,
                        value: _isImportant,
                        onChanged: (bool? value) {
                          setState(() {
                            _isImportant = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Star This Entry as Important',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Save Entry'),
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
