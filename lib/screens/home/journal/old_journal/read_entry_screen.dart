import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ViewUpdateEntryScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const ViewUpdateEntryScreen({
    Key? key,
    required this.documentId,
    required this.data,
  }) : super(key: key);

  @override
  _ViewUpdateEntryScreenState createState() => _ViewUpdateEntryScreenState();
}

class _ViewUpdateEntryScreenState extends State<ViewUpdateEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _healthProblemController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _healthGoalsController = TextEditingController();
  final TextEditingController _memoriesController = TextEditingController();
  DateTime? _selectedDate;
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
    _titleController.text = widget.data['title'] ?? '';
    _descriptionController.text = widget.data['description'] ?? '';
    _reflectionController.text = widget.data['reflection'] ?? '';
    _moodController.text = widget.data['mood'] ?? '';
    _healthProblemController.text = widget.data['health_problem'] ?? '';
    _medicineNameController.text = widget.data['medicine_name'] ?? '';
    _healthGoalsController.text = widget.data['health_goals'] ?? '';
    _memoriesController.text = widget.data['memories'] ?? '';
    _selectedDate = (widget.data['date'] as Timestamp?)?.toDate();
    _imageUrls = List<String>.from(widget.data['images'] ?? []);
    _isImportant = widget.data['isImportant'] ?? false;
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
        'reflection': _reflectionController.text,
        'mood': _moodController.text,
        'health_problem': _healthProblemController.text,
        'medicine_name': _medicineNameController.text,
        'health_goals': _healthGoalsController.text,
        'memories': _memoriesController.text,
        'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your $label',
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
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            maxLines: maxLines,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View and Update Entry'),
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
              _buildTextField('Title', _titleController),
              _buildTextField('Description', _descriptionController, maxLines: 5),
              _buildTextField('Reflection', _reflectionController, maxLines: 5),
              _buildTextField('Mood', _moodController),
              _buildTextField('Health Problem', _healthProblemController),
              _buildTextField('Medicine Name', _medicineNameController),
              _buildTextField('Health Goals', _healthGoalsController, maxLines: 5),
              _buildTextField('Memories', _memoriesController, maxLines: 5),
              const SizedBox(height: 20),
              const Text(
                'Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
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
