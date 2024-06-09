import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../adult_journal/update_outing_entry_screen.dart';
import '../adult_journal/update_personal_entry_screen.dart';
import '../kids_journal/update_entry_screen.dart';
import 'update_daily_entry_screen.dart';
import 'update_health_entry_screen.dart';

class ReadEntryScreen extends StatelessWidget {
  final String documentId;

  const ReadEntryScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('entries').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Entry not found', style: TextStyle(color: Colors.white)));
          }

          var entry = snapshot.data!;
          var data = entry.data() as Map<String, dynamic>;
          var title = data['title'] ?? 'No Title';
          var description = data['description'] ?? 'No Description';
          var reflection = data['reflection'] ?? 'No Reflection';
          var mood = data['mood'] ?? 'No Mood';
          var healthProblem = data['health_problem'] ?? 'No Health Problem';
          var medicineName = data['medicine_name'] ?? 'No Medicine Name';
          var healthGoals = data['health_goals'] ?? 'No Health Goals';
          var memories = data['memories'] ?? 'No Memories';
          var date = (data['date'] as Timestamp?)?.toDate();
          var imageUrls = List<String>.from(data['images'] ?? []);
          bool isImportant = data['isImportant'] ?? false;

          String templateType;
          if (title.startsWith('Daily:')) {
            templateType = 'daily';
          } else if (title.startsWith('Personal:')) {
            templateType = 'personal';
          } else if (title.startsWith('Health:')) {
            templateType = 'health';
          } else {
            templateType = 'general';
          }

          return Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (templateType == 'outing') ...[
                    const Text(
                      'Place',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['place'] ?? 'No Place',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Memories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['memories'] ?? 'No Memories',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['reflection'] ?? 'No Reflection',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null ? DateFormat('yyyy-MM-dd').format(date) : 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'personal') ...[
                    const Text(
                      'Mood',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['mood'] ?? 'No Mood',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Memories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['memories'] ?? 'No Memories',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['reflection'] ?? 'No Reflection',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null ? DateFormat('yyyy-MM-dd').format(date) : 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'daily') ...[
                    const Text(
                      'Mood',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['mood'] ?? 'No Mood',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No Description',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['reflection'] ?? 'No Reflection',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null ? DateFormat('yyyy-MM-dd').format(date) : 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'health') ...[
                    const Text(
                      'Health Problem',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['health_problem'] ?? 'No Health Problem',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Medicine Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['medicine_name'] ?? 'No Medicine Name',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Health Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['health_goals'] ?? 'No Health Goals',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null ? DateFormat('yyyy-MM-dd').format(date) : 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                    children: imageUrls.map<Widget>((imageUrl) {
                      return Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        isImportant ? Icons.star : Icons.star_border,
                        color: isImportant ? Colors.yellow : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Important Entry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (templateType == 'outing') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateOutingEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialPlace: data['place'] ?? 'No Place',
                              initialDescription: description,
                              initialMemories: data['memories'] ?? 'No Memories',
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialDate: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                              initialImages: List<String>.from(imageUrls),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'personal') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePersonalEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialMood: data['mood'] ?? 'No Mood',
                              initialMemories: data['memories'] ?? 'No Memories',
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialImages: List<String>.from(imageUrls),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'daily') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateDailyEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialMood: data['mood'] ?? 'No Mood',
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialImages: List<String>.from(imageUrls),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'health') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateHealthEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialHealthProblem: data['health_problem'] ?? 'No Health Problem',
                              initialMedicineName: data['medicine_name'] ?? 'No Medicine Name',
                              initialHealthGoals: data['health_goals'] ?? 'No Health Goals',
                              initialImages: List<String>.from(imageUrls),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialImages: List<String>.from(imageUrls),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Update Entry', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),

                    ),
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
