import 'package:apha_journal/shop/select_journal_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shop/sticker_model.dart'; // Import the Sticker model

class MyStickersScreen extends StatefulWidget {
  @override
  _MyStickersScreenState createState() => _MyStickersScreenState();
}

class _MyStickersScreenState extends State<MyStickersScreen> {
  late Future<List<Sticker>> purchasedStickers;

  @override
  void initState() {
    super.initState();
    purchasedStickers = fetchPurchasedStickers();
  }

  Future<List<Sticker>> fetchPurchasedStickers() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    List<dynamic> stickerIds = userDoc['purchasedStickers'] ?? [];
    if (stickerIds.isEmpty) {
      return [];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('stickers')
        .where(FieldPath.documentId, whereIn: stickerIds)
        .get();

    return snapshot.docs.map((doc) => Sticker.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Stickers'),
      ),
      body: FutureBuilder<List<Sticker>>(
        future: purchasedStickers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No purchased stickers available'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Sticker sticker = snapshot.data![index];
                return StickerCard(
                  sticker: sticker,
                  onStickerSelected: () {
                    _selectJournalEntryForSticker(context, sticker);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _selectJournalEntryForSticker(BuildContext context, Sticker sticker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectJournalEntryScreen(sticker: sticker, stickerId: '',),
      ),
    );
  }
}

class StickerCard extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback onStickerSelected;

  StickerCard({required this.sticker, required this.onStickerSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850], // Dark background for the card
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              sticker.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes as int)
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                print('Error loading image: $exception'); // Log the error
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      Text('Failed to load image', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(sticker.name, style: TextStyle(fontSize: 16, color: Colors.white)),
                ElevatedButton(
                  onPressed: onStickerSelected, // Select this sticker to add to a journal entry
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), // Customize button color
                  child: Text('Use'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
