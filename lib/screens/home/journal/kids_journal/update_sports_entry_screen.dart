import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UpdateSportsEntryScreen extends StatefulWidget {
  final String documentId;
  final String initialTitle;
  final String initialDescription;
  final String initialEvent;
  final String initialAchievement;
  final List<String> initialImages;
  final bool isImportant;

  const UpdateSportsEntryScreen({
    super.key,
    required this.documentId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialEvent,
    required this.initialAchievement,
    required this.initialImages,
    required this.isImportant,
  });

  @override
  _UpdateSportsEntryScreenState createState() => _UpdateSportsEntryScreenState();
}

class _UpdateSportsEntryScreenState extends State<UpdateSportsEntryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: 'gs://alpha-journal-app.appspot.com',
  );
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _eventController;
  late TextEditingController _achievementController;
  late List<String> _imageUrls;
  late List<File> _newImages;
  late bool _isImportant;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _eventController = TextEditingController(text: widget.initialEvent);
    _achievementController = TextEditingController(text: widget.initialAchievement);
    _imageUrls = widget.initialImages;
    _newImages = [];
    _isImportant = widget.isImportant;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _updateEntry() async {
    if (_formKey.currentState!.validate()) {
      List<String> imageUrls = await _uploadNewImages();
      imageUrls.addAll(_imageUrls);
      try {
        await firestore.collection('entries').doc(widget.documentId).update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'event': _eventController.text,
          'achievement': _achievementController.text,
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
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> imageUrls = [];
    for (File image in _newImages) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = storage.ref().child('journal_entries/$fileName');
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
        title: const Text('Update Sports Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.grey[800],
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.grey[800],
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventController,
                  decoration: InputDecoration(
                    labelText: 'Event',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.grey[800],
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _achievementController,
                  decoration: InputDecoration(
                    labelText: 'Achievement',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.grey[800],
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _imageUrls.map<Widget>((imageUrl) {
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
                  }).toList()
                    ..addAll(_newImages.map<Widget>((image) {
                      return Stack(
                        children: [
                          Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
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
                    }).toList())
                    ..add(
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
                    ),
                ),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 8),
                    const Text(
                      'Star This Entry as Important',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: _updateEntry,
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
