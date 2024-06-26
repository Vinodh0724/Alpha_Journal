import 'dart:math';
import 'package:apha_journal/screens/home/journal/old_journal/daily_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/old_journal/health_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/old_journal/personal_entry_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_entry_screen.dart';
import 'read_entry_screen.dart';



class OldJournalScreen extends StatefulWidget {
  const OldJournalScreen({Key? key}) : super(key: key);

  @override
  _OldJournalScreenState createState() => _OldJournalScreenState();
}

class _OldJournalScreenState extends State<OldJournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  String searchQuery = '';
  List<String> tags = []; // Initialize tags list here

  bool showAllEntries = false;

  void _navigateToTemplate(String templateType) {
    switch (templateType) {
      case 'Daily':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyEntryScreen(), // Navigate to SchoolEntryScreen
          ),
        );
        break;
      case 'Personal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalEntryScreen(), // Navigate to SportsEntryScreen
          ),
        );
        break;
      case 'Health':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthEntryScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _deleteEntry(String entryId) {
    _firestore.collection('entries').doc(entryId).delete();
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
        title: Text('Welcome to Elders Journal!'),
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
                        onPressed: () => _navigateToTemplate('Daily'),
                        child: Text('Daily'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('Personal'),
                        child: Text('Personal'),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTemplate('Health'),
                        child: Text('Health'),
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

                if (showAllEntries) {
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      var entry = entries[index];
                      var images = entry['images'] as List<dynamic>;
                      bool isImportant = (entry.data() as Map<String, dynamic>).containsKey('isImportant') && (entry['isImportant'] as bool? ?? false);

                      // Generate a random color
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
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isImportant)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Icon(Icons.star, color: Colors.yellow),
                                ),
                              SizedBox(width: isImportant ? 8.0 : 0), // Add space if star icon is present
                              Expanded(
                                child: Text(
                                  entry['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Times New Roman'),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              entry['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17, fontFamily: 'Times New Roman'), // Thin and bold
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (images.isNotEmpty) Image.network(images.first, width: 50, height: 50),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteEntry(entry.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Update tags list only with important entries
                  tags = entries
                      .where((doc) => (doc.data() as Map<String, dynamic>).containsKey('isImportant') && (doc['isImportant'] as bool))
                      .map((doc) => doc['title'] as String)
                      .toList();

                  // Filter entries based on search query
                  var filteredEntries = entries.where((entry) {
                    var title = entry['title'] as String;
                    return title.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      var entry = filteredEntries[index];
                      var images = entry['images'] as List<dynamic>;
                      bool isImportant = (entry.data() as Map<String, dynamic>).containsKey('isImportant') && (entry['isImportant'] as bool? ?? false);

                      // Generate a random color
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
                }
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

