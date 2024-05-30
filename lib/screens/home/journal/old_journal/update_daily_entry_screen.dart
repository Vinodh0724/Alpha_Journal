import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UpdateDailyEntryScreen extends StatefulWidget {
  final String documentId;
  final String initialTitle;
  final String initialDescription;
  final String initialMood;
  final String initialReflection;
  final List<String> initialImages;
  final bool isImportant;

  const UpdateDailyEntryScreen({
    Key? key,
    required this.documentId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialMood,
    required this.initialReflection,
    required this.initialImages,
    required this.isImportant, DateTime? initialDate,
  }) : super(key: key);

  @override
  _UpdateDailyEntryScreenState createState() => _UpdateDailyEntryScreenState();
}

class _UpdateDailyEntryScreenState extends State<UpdateDailyEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  List<String> _imageUrls = [];
  List<XFile> _newImages = [];
  bool _isImportant = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com',
  );

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription;
    _moodController.text = widget.initialMood;
    _reflectionController.text = widget.initialReflection;
    _imageUrls = widget.initialImages;
    _isImportant = widget.isImportant;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImages.add(pickedFile);
      });
    }
  }

  Future<void> _updateEntry() async {
    if (_titleController.text.isNotEmpty) {
      List<String> newImageUrls = await _uploadImages();
      newImageUrls.addAll(_imageUrls);

      await _firestore.collection('entries').doc(widget.documentId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'mood': _moodController.text,
        'reflection': _reflectionController.text,
        'images': newImageUrls,
        'isImportant': _isImportant,
      });
      Navigator.pop(context);
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (XFile image in _newImages) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('journal_entries/$fileName');
      await storageRef.putFile(File(image.path));
      String downloadUrl = await storageRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Daily Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateEntry,
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
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
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                  ..._imageUrls.map((imageUrl) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _imageUrls.remove(imageUrl);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  ..._newImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(image.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _newImages.remove(image);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter your daily journal entry title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter your daily journal entry description',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _moodController,
                decoration: InputDecoration(
                  hintText: 'Enter your mood for today',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reflection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextField(
                controller: _reflectionController,
                decoration: InputDecoration(
                  hintText: 'Enter your daily journal entry reflection',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isImportant,
                    onChanged: (bool? value) {
                      setState(() {
                        _isImportant = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Star This Entry as Important',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Entry'),
                  onPressed: _updateEntry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
