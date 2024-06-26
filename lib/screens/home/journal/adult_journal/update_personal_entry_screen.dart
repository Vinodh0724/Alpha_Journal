// TODO Implement this library.import 'dart:io';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdatePersonalEntryScreen extends StatefulWidget {
  final String documentId;
  final String initialTitle;
  final String initialDescription;
  final String initialMemories;
  final String initialMood;
  final String initialReflection;
  //final DateTime initialDate;
  final List<String> initialImages;
  final bool isImportant;

  const UpdatePersonalEntryScreen({
    super.key,
    required this.documentId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialMemories,
    required this.initialMood,
    required this.initialReflection,
    //required this.initialDate,
    required this.initialImages,
    required this.isImportant,
  });

  @override
  _UpdatePersonalEntryScreenState createState() => _UpdatePersonalEntryScreenState();
}

class _UpdatePersonalEntryScreenState extends State<UpdatePersonalEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _memoriesController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  DateTime? _selectedDate;
  late List<String> _imageUrls;
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
    _memoriesController.text = widget.initialMemories;
    _moodController.text = widget.initialMood;
    _reflectionController.text = widget.initialReflection;
   // _selectedDate = widget.initialDate;
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
    List<String> imageUrls = await _uploadNewImages();
    imageUrls.addAll(_imageUrls);

    try {
      await _firestore.collection('entries').doc(widget.documentId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'memories': _memoriesController.text,
        'mood': _moodController.text,
        'reflection': _reflectionController.text,
        'images': imageUrls,
        'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'isImportant': _isImportant,
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update entry: $e')),
      );
    }
  }

  Future<List<String>> _uploadNewImages() async {
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
        title: const Text('Update Personal Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Add Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          color: const Color.fromARGB(255, 34, 33, 33),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color.fromARGB(255, 43, 255, 0), width: 2),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.white),
                      ),
                    ),
                    ..._imageUrls.map((imageUrl) {
                      return Stack(
                        children: [
                          Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Color.fromARGB(255, 255, 0, 0)),
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
                          Image.file(File(image.path), width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Color.fromARGB(255, 255, 0, 0)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter your journal entry title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select Date',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter your journal entry description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Memories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _memoriesController,
                  decoration: InputDecoration(
                    hintText: 'Enter your memorable moments',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mood',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _moodController,
                  decoration: InputDecoration(
                    hintText: 'Enter your mood',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Reflection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _reflectionController,
                  decoration: InputDecoration(
                    hintText: 'Reflect on your day',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 10),
                    const Text(
                      'Star this Entry as Important',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
      ),
    );
  }
}
