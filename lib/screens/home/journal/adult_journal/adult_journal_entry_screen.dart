import 'dart:math';
import 'package:apha_journal/screens/home/journal/adult_journal/outing_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/adult_journal/personal_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/adult_journal/work_entry_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_entry_screen.dart';
import 'read_entry_screen.dart';

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
      case 'Work':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkEntryScreen(),
          ),
        );
        break;
      case 'Personal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalEntryScreen(),
          ),
        );
        break;
      case 'Outing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutingEntryScreen(),
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

void _navigateToReadEntry(String entryId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReadEntryScreen(documentId: entryId),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Adults Journal!'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
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
                  label: Text('Show All'),
                  labelStyle: TextStyle(color: Colors.black),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  onPressed: () {
                    setState(() {
                      showAllEntries = true;
                    });
                  },
                ),
                ...tags.map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    labelStyle: TextStyle(color: Colors.black),
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 1100,
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
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('Work'),
                        child: Text('Work'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('Personal'),
                        child: Text('Personal'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('Outing'),
                        child: Text('Outing'),
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
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
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
                        leading: isImportant ? Icon(Icons.star, color: Colors.yellow) : SizedBox(width: 24),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Times New Roman'),
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
                              icon: Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteEntry(entry.id),
                            ),
                          ],
                        ),
                            onTap: () => _navigateToReadEntry(entry.id),
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
            MaterialPageRoute(builder: (context) => AddEntryScreen()),
          ).then((_) {
            // Optionally, you could refresh the state here if needed
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
