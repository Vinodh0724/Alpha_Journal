import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../kids_journal/update_entry_screen.dart';
import 'update_outing_entry_screen.dart';
import 'update_personal_entry_screen.dart';
import 'update_work_entry_screen.dart';

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
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Entry not found', style: TextStyle(color: Colors.white)));
          }

          var entry = snapshot.data!;
          var data = entry.data() as Map<String, dynamic>;
          var title = data['title'] ?? 'No Title';
          var description = data['description'] ?? 'No Description';
          var stickers = data['stickers'] ?? []; // Added to fetch stickers
          var images = data['images'] ?? [];
          bool isImportant = data['isImportant'] ?? false;

          String templateType;
          if (title.startsWith('Outing:')) {
            templateType = 'outing';
          } else if (title.startsWith('Personal:')) {
            templateType = 'personal';
          } else if (title.startsWith('Work:')) {
            templateType = 'work';
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (templateType == 'outing') ...[
                    Text(
                      'Place',
                      style: const TextStyle(
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
                    Text(
                      'Memories',
                      style: const TextStyle(
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
                      'Date',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (data['date'] as Timestamp?)?.toDate().toString() ?? 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'personal') ...[
                    Text(
                      'Description',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    Text(
                      'Mood',
                      style: const TextStyle(
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
                    Text(
                      'Memories',
                      style: const TextStyle(
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
                      'Date',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (data['date'] as Timestamp?)?.toDate().toString() ?? 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (templateType == 'work') ...[
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
                    const SizedBox(height: 16),
                    Text(
                      'Job Worked',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['job_worked'] ?? 'No Job',
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
                      'Date',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (data['date'] as Timestamp?)?.toDate().toString() ?? 'No Date',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (stickers.isNotEmpty) ...[
  const SizedBox(height: 16),
  Text(
    'Stickers',
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
    children: stickers.map<Widget>((stickerUrl) {
      return Image.network(stickerUrl, width: 50, height: 50, fit: BoxFit.cover);
    }).toList(),
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
                              initialImages: List<String>.from(images),
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
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            ),
                          ),
                        );
                      } else if (templateType == 'work') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateWorkEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialJobWorked: data['job_worked'] ?? 'No Job',
                              initialDescription: description,
                              initialAchievements: data['achievements'] ?? 'No Achievements',
                              initialReflection: data['reflection'] ?? 'No Reflection',
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
