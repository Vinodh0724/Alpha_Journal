import 'dart:math';
import 'package:apha_journal/screens/home/journal/kids_journal/school_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/kids_journal/sports_entry_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  String searchQuery = '';
  List<String> tags = [];

  void _navigateToTemplate(String templateType) {
    Map<String, String> templateData;
    switch (templateType) {
      case 'school':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolEntryScreen(), // Navigate to SchoolEntryScreen
        ),
      );
      break;
      case 'sports':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SportsEntryScreen(), // Navigate to SchoolEntryScreen
        ),
      );
      break;
      case 'tuition':
        templateData = {
          'title': 'Tuition',
          'description': 'Tuition classes and learning notes.',
        };
        break;
      default:
        templateData = {
          'title': '',
          'description': '',
        };
        break;
    }

    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          templateData: templateData,
        ),
      ),
    );*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('entries').where('userId', isEqualTo: user?.uid).orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No entries yet.'));
                }

                var entries = snapshot.data!.docs;

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

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: tags.map((tag) {
                          return ActionChip(
                            label: Text(tag),
                            labelStyle: TextStyle(color: Colors.black),
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                searchQuery = tag;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      width: 1000,
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
                                onPressed: () => _navigateToTemplate('school'),
                                child: Text('School'),
                              ),
                              ElevatedButton(
                                onPressed: () => _navigateToTemplate('sports'),
                                child: Text('Sports'),
                              ),
                              ElevatedButton(
                                onPressed: () => _navigateToTemplate('tuition'),
                                child: Text('Tuition'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
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
                              title: Text(
                                entry['title'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Times New Roman'),
                              ),
                              subtitle: Text(
                                entry['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17, fontFamily: 'Times New Roman'), // Thin and bold
                              ),
                              trailing: images.isNotEmpty
                                  ? Image.network(images.first, width: 50, height: 50)
                                  : null,
                              leading: isImportant ? Icon(Icons.star, color: Colors.yellow) : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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