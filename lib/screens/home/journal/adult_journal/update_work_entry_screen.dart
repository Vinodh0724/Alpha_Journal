import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateWorkEntryScreen extends StatefulWidget {
  final String documentId;
  final String initialTitle;
  final String initialJobWorked;
  final String initialDescription;
  final String initialReflection;
  final String initialAchievements;
  //final DateTime initialDate;
  final List<String> initialImages;
  final bool isImportant;

  const UpdateWorkEntryScreen({
    super.key,
    required this.documentId,
    required this.initialTitle,
    required this.initialJobWorked,
    required this.initialDescription,
    required this.initialReflection,
    required this.initialAchievements,
   // required this.initialDate,
    required this.initialImages,
    required this.isImportant,
  });

  @override
  _UpdateWorkEntryScreenState createState() => _UpdateWorkEntryScreenState();
}

class _UpdateWorkEntryScreenState extends State<UpdateWorkEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _jobWorkedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  DateTime? _selectedDate;
  late List<String> _imageUrls;
  final List<XFile> _newImages = [];
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
    _jobWorkedController.text = widget.initialJobWorked;
    _descriptionController.text = widget.initialDescription;
    _reflectionController.text = widget.initialReflection;
    _achievementsController.text = widget.initialAchievements;
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
        'job_worked': _jobWorkedController.text,
        'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'description': _descriptionController.text,
        'reflection': _reflectionController.text,
        'achievements': _achievementsController.text,
        'images': imageUrls,
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
        title: const Text('Update Work Entry'),
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
                    }),
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
                    }),
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
                    hintText: 'Enter your work journal entry title',
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
                  'Job Worked',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _jobWorkedController,
                  decoration: InputDecoration(
                    hintText: 'Enter the job you worked',
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
                    hintText: 'Enter your work journal entry description',
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
                  'Reflection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _reflectionController,
                  decoration: InputDecoration(
                    hintText: 'Enter your work journal entry reflection',
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
                  'Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _achievementsController,
                  decoration: InputDecoration(
                    hintText: 'Enter your work journal entry achievements',
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
                      'Star This Entry as Important',
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
