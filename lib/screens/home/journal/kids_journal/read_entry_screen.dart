import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_entry_screen.dart';
import 'update_school_entry_screen.dart';
import 'update_sports_entry_screen.dart';
import 'update_tuition_entry_screen.dart';

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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Entry not found'));
          }

          var entry = snapshot.data!;
          var data = entry.data() as Map<String, dynamic>;
          var title = data['title'] ?? 'No Title';
          var description = data['description'] ?? 'No Description';
          var images = data['images'] ?? [];
          bool isImportant = data['isImportant'] ?? false;

          String templateType;
          if (title.startsWith('School:')) {
            templateType = 'school';
          } else if (title.startsWith('Sports:')) {
            templateType = 'sports';
          } else if (title.startsWith('Tuition:')) {
            templateType = 'tuition';
          } else {
            templateType = 'general';
          }
 
          return Padding(
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
                      color: Colors.white, // Ensure text is visible
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Ensure text is visible
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (templateType == 'school') ...[
                    Text(
                      'Reflection',
                      style: const TextStyle(
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
                    Text(
                      'Achievements',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['achievements'] ?? 'No Achievements',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'sports') ...[
                    Text(
                      'Event',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['event'] ?? 'No Event',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Achievement',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['achievement'] ?? 'No Achievement',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'tuition') ...[
                    Text(
                      'Experience',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['experience'] ?? 'No Experience',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fees',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['fees'] ?? 'No Fees',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Subject',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['subject'] ?? 'No Subject',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Images',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: images.map<Widget>((imageUrl) {
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
                      Text(
                        'Important Entry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (templateType == 'school') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateSchoolEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialAchievements: data['achievements'] ?? 'No Achievements',
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'sports') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateSportsEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialEvent: data['event'] ?? 'No Event',
                              initialAchievement: data['achievement'] ?? 'No Achievement',
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'tuition') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateTuitionEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialExperience: data['experience'] ?? 'No Experience',
                              initialFees: data['fees'] ?? 'No Fees',
                              initialSubject: data['subject'] ?? 'No Subject',
                              initialImages: List<String>.from(images),
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
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('Update Entry'),
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
