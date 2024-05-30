import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adult_view_entry_screen.dart';
import '../add_entry_screen.dart';
import 'outing_entry_screen.dart';
import 'personal_entry_screen.dart';
import 'update_outing_entry_screen.dart';
import 'update_personal_entry_screen.dart';
import 'update_work_entry_screen.dart';
import 'work_entry_screen.dart';

class AdultJournalScreen extends StatefulWidget {
  const AdultJournalScreen({Key? key}) : super(key: key);

  @override
  _AdultJournalScreenState createState() => _AdultJournalScreenState();
}

class _AdultJournalScreenState extends State<AdultJournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  String searchQuery = '';
  List<String> tags = [];

  bool showAllEntries = false;

  void _navigateToTemplate(String templateType) {
    switch (templateType) {
      case 'work':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkEntryScreen(),
          ),
        );
        break;
      case 'personal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalEntryScreen(),
          ),
        );
        break;
      case 'outing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OutingEntryScreen(),
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
        title: const Text('Adult Journal'),
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
                }).toList(),
              ],
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
                    var title = entry['title'] ?? 'No Title';
                    var description = entry['description'] ?? 'No Description';
                    var templateType = title.toString().split(':').first.toLowerCase();

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
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Times New Roman'),
                          ),
                        ),
                        subtitle: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            description,
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
                              builder: (context) => AdultViewEntryScreen(
                                documentId: entry.id,
                                templateType: templateType,
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
          _navigateToTemplate('outing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
