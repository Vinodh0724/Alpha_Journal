import 'dart:math';
import 'package:apha_journal/screens/home/journal/adult_journal/update_outing_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/adult_journal/update_personal_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/adult_journal/update_work_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AdultJournalScreen extends StatefulWidget {
  const AdultJournalScreen({Key? key}) : super(key: key);

  @override
  _AdultJournalScreenState createState() => _AdultJournalScreenState();
}

class _AdultJournalScreenState extends State<AdultJournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';
  bool showAllEntries = false;

  Future<void> _deleteEntry(String entryId) async {
    try {
      await _firestore.collection('entries').doc(entryId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adult Journal Entries'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('entries')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No entries yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var entries = snapshot.data!.docs;
                var filteredEntries = entries;

                if (!showAllEntries && searchQuery.isNotEmpty) {
                  filteredEntries = entries.where((entry) {
                    var title = entry['title'] as String;
                    return title.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();
                }

                return ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    var entry = filteredEntries[index];
                    var images = entry['images'] as List<dynamic>;
                    bool isImportant = (entry.data() as Map<String, dynamic>).containsKey('isImportant') &&
                        (entry['isImportant'] as bool? ?? false);
                    final templateType = entry['title'].split(':').first.toLowerCase();

                    final random = Random();
                    final Color randomColor = Color.fromRGBO(
                      random.nextInt(256),
                      random.nextInt(256),
                      random.nextInt(256),
                      1,
                    );

                    return Card(
                      color: randomColor,
                      child: ListTile(
                        leading: isImportant ? const Icon(Icons.star, color: Colors.yellow) : const SizedBox(width: 24),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        ),
                        subtitle: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            images.isNotEmpty
                                ? Image.network(images.first, width: 50, height: 50)
                                : Container(),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteEntry(entry.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToUpdateScreen(templateType, entry);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUpdateScreen(String templateType, QueryDocumentSnapshot entry) {
    final documentId = entry.id;
    final data = entry.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'No Title';
    final description = data['description'] ?? 'No Description';
    final images = data['images'] as List<dynamic>;
    final isImportant = data['isImportant'] ?? false;

    if (templateType == 'outing') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateOutingEntryScreen(
            documentId: documentId,
            initialTitle: title,
            initialDescription: description,
            initialPlace: data['place'] ?? 'No Place',
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
            initialMemories: data['memories'] ?? 'No Memories',
            initialMood: data['mood'] ?? 'No Mood',
            initialReflection: data['reflection'] ?? 'No Reflection',
           // initialDate: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
            initialJobWorked: data['job_worked'] ?? 'No Job Worked',
            initialDescription: description,
            initialReflection: data['reflection'] ?? 'No Reflection',
            initialAchievements: data['achievements'] ?? 'No Achievements',
          //  initialDate: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            initialImages: List<String>.from(images),
            isImportant: isImportant,
          ),
        ),
      );
    }
  }
}
