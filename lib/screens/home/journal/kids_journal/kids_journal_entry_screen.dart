import 'dart:math';
import 'package:apha_journal/screens/home/journal/kids_journal/school_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/kids_journal/sports_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/kids_journal/tuition_entry_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_entry_screen.dart';
import 'read_entry_screen.dart';



class KidsJournalScreen extends StatefulWidget {
  const KidsJournalScreen({super.key});

  @override
  _KidsJournalScreenState createState() => _KidsJournalScreenState();
}

class _KidsJournalScreenState extends State<KidsJournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  String searchQuery = '';
  List<String> tags = [];

  bool showAllEntries = false;

  void _navigateToTemplate(String templateType) {
    switch (templateType) {
      case 'school':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SchoolEntryScreen(),
          ),
        );
        break;
      case 'sports':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SportsEntryScreen(),
          ),
        );
        break;
      case 'tuition':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TuitionEntryScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

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
        title: const Text('Welcome to Kids Journal!'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ActionChip(
                  label: const Text('Show All'),
                  labelStyle: const TextStyle(color: Colors.black),
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  onPressed: () {
                    setState(() {
                      showAllEntries = true;
                    });
                  },
                ),
                ...tags.map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    labelStyle: const TextStyle(color: Colors.black),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    onPressed: () {
                      setState(() {
                        searchQuery = tag;
                        showAllEntries = false;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 97, 63, 7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Entries for You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('school'),
                        child: const Text('School'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('sports'),
                        child: const Text('Sports'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('tuition'),
                        child: const Text('Tuition'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('entries').where('userId', isEqualTo: user?.uid).orderBy('timestamp', descending: true).snapshots(),
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
                    bool isImportant = (entry.data() as Map<String, dynamic>).containsKey('isImportant') && (entry['isImportant'] as bool? ?? false);

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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Times New Roman'),
                          ),
                        ),
                        subtitle: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17, fontFamily: 'Times New Roman'),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadEntryScreen(
                                documentId: entry.id,
                              ),
                            ),
                          );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          ).then((_) {
            // Optionally, you could refresh the state here if needed
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

