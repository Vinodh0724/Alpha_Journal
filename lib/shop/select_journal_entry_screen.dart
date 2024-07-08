import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shop/sticker_model.dart'; // Import the Sticker model

class SelectJournalEntryScreen extends StatelessWidget {
  final Sticker sticker;

  SelectJournalEntryScreen({required this.sticker, required String stickerId});

  Future<List<DocumentSnapshot>> fetchJournalEntries() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('entries')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    return snapshot.docs;
  }

  Future<void> _addStickerToJournalEntry(String journalEntryId) async {
    await FirebaseFirestore.instance
        .collection('entries')
        .doc(journalEntryId)
        .update({
      'stickers': FieldValue.arrayUnion([sticker.imageUrl]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Journal Entry'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No journal entries available', style: TextStyle(color: Colors.white)));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(8.0), // Add padding around the list
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                DocumentSnapshot journalEntry = snapshot.data![index];
                return GestureDetector(
                  onTap: () async {
                    await _addStickerToJournalEntry(journalEntry.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sticker added to journal entry!')),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journalEntry['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          journalEntry['description'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
