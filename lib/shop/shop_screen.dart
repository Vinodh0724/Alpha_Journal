import 'package:apha_journal/shop/my_stickers_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shop/sticker_model.dart';
import 'select_journal_entry_screen.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<Sticker>> stickers;

  @override
  void initState() {
    super.initState();
    stickers = fetchStickers();
  }

  Future<List<Sticker>> fetchStickers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('stickers').get();
    return snapshot.docs.map((doc) => Sticker.fromFirestore(doc)).toList();
  }

  void _selectJournalEntryForSticker(BuildContext context, Sticker sticker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectJournalEntryScreen(sticker: sticker, stickerId: ''),
      ),
    );
  }

  Future<void> _buySticker(BuildContext context, Sticker sticker) async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Fetch user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      int currentPoints = userData['points'];
      List<dynamic> purchasedStickers = userData.containsKey('purchasedStickers') ? userData['purchasedStickers'] : [];

      if (purchasedStickers.contains(sticker.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already purchased this sticker')),
        );
        return;
      }

      if (currentPoints < sticker.price) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough points')),
        );
        return;
      }

      // Deduct points and update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'points': currentPoints - sticker.price,
        'purchasedStickers': FieldValue.arrayUnion([sticker.id]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sticker purchased!')),
      );

      // Navigate to select journal entry screen
      _selectJournalEntryForSticker(context, sticker);

      // Refresh the state
      setState(() {
        stickers = fetchStickers();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sticker Shop'),
        actions: [
          IconButton(
            icon: Icon(Icons.sticky_note_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyStickersScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Sticker>>(
        future: stickers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No stickers available', style: TextStyle(color: Colors.white)));
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
                return StickerCard(sticker: sticker, onBuyPressed: _buySticker);
              },
            );
          }
        },
      ),
    );
  }
}

class StickerCard extends StatelessWidget {
  final Sticker sticker;
  final Future<void> Function(BuildContext context, Sticker sticker) onBuyPressed;

  StickerCard({required this.sticker, required this.onBuyPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
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
                Text('${sticker.price} points', style: TextStyle(fontSize: 14, color: Colors.white70)),
                SizedBox(height: 8), // Add some space before the button
                ElevatedButton(
                  onPressed: () => onBuyPressed(context, sticker), // Use the passed method
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), // Customize button color
                  child: Text('Buy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
