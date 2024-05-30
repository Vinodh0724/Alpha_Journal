import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'update_outing_entry_screen.dart';
import 'update_personal_entry_screen.dart';
import 'update_work_entry_screen.dart';

class AdultViewEntryScreen extends StatelessWidget {
  final String documentId;
  final String templateType;

  const AdultViewEntryScreen({
    Key? key,
    required this.documentId,
    required this.templateType,
  }) : super(key: key);

  Future<DocumentSnapshot> getEntryDetails() async {
    return FirebaseFirestore.instance.collection('entries').doc(documentId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getEntryDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Entry not found.'),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var title = data['title'] ?? 'No Title';
        var description = data['description'] ?? 'No Description';
        var images = data['images'] as List<dynamic>? ?? [];
        var isImportant = data['isImportant'] ?? false;

        var additionalInfo = <String, dynamic>{};
        if (templateType == 'work') {
          additionalInfo['Job Worked'] = data['job_worked'] ?? 'No Job';
          additionalInfo['Achievements'] = data['achievements'] ?? 'No Achievements';
          additionalInfo['Reflection'] = data['reflection'] ?? 'No Reflection';
        } else if (templateType == 'personal') {
          additionalInfo['Memories'] = data['memories'] ?? 'No Memories';
          additionalInfo['Mood'] = data['mood'] ?? 'No Mood';
          additionalInfo['Reflection'] = data['reflection'] ?? 'No Reflection';
        } else if (templateType == 'outing') {
          additionalInfo['Place'] = data['place'] ?? 'No Place';
          additionalInfo['Memories'] = data['memories'] ?? 'No Memories';
          additionalInfo['Reflection'] = data['reflection'] ?? 'No Reflection';
          additionalInfo['Date'] = (data['date'] as Timestamp?)?.toDate() ?? 'No Date';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        switch (templateType) {
                          case 'work':
                            return UpdateWorkEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialJobWorked: data['job_worked'] ?? 'No Job',
                              initialDescription: description,
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialAchievements: data['achievements'] ?? 'No Achievements',
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            );
                          case 'personal':
                            return UpdatePersonalEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialDescription: description,
                              initialMemories: data['memories'] ?? 'No Memories',
                              initialMood: data['mood'] ?? 'No Mood',
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            );
                          case 'outing':
                            return UpdateOutingEntryScreen(
                              documentId: documentId,
                              initialTitle: title,
                              initialPlace: data['place'] ?? 'No Place',
                              initialDescription: description,
                              initialMemories: data['memories'] ?? 'No Memories',
                              initialReflection: data['reflection'] ?? 'No Reflection',
                              initialDate: (data['date'] as Timestamp?)?.toDate(),
                              initialImages: List<String>.from(images),
                              isImportant: isImportant,
                            );
                          default:
                            return const Center(child: Text('Invalid Template'));
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          body: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                if (isImportant)
                  const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                ...additionalInfo.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  );
                }).toList(),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: images.map((imageUrl) {
                    return Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          switch (templateType) {
                            case 'work':
                              return UpdateWorkEntryScreen(
                                documentId: documentId,
                                initialTitle: title,
                                initialJobWorked: data['job_worked'] ?? 'No Job',
                                initialDescription: description,
                                initialReflection: data['reflection'] ?? 'No Reflection',
                                initialAchievements: data['achievements'] ?? 'No Achievements',
                                initialImages: List<String>.from(images),
                                isImportant: isImportant,
                              );
                            case 'personal':
                              return UpdatePersonalEntryScreen(
                                documentId: documentId,
                                initialTitle: title,
                                initialDescription: description,
                                initialMemories: data['memories'] ?? 'No Memories',
                                initialMood: data['mood'] ?? 'No Mood',
                                initialReflection: data['reflection'] ?? 'No Reflection',
                                initialImages: List<String>.from(images),
                                isImportant: isImportant,
                              );
                            case 'outing':
                              return UpdateOutingEntryScreen(
                                documentId: documentId,
                                initialTitle: title,
                                initialPlace: data['place'] ?? 'No Place',
                                initialDescription: description,
                                initialMemories: data['memories'] ?? 'No Memories',
                                initialReflection: data['reflection'] ?? 'No Reflection',
                                initialDate: (data['date'] as Timestamp?)?.toDate(),
                                initialImages: List<String>.from(images),
                                isImportant: isImportant,
                              );
                            default:
                              return const Center(child: Text('Invalid Template'));
                          }
                        },
                      ),
                    );
                  },
                  child: const Text('Update Entry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
