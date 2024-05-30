// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'update_outing_entry_screen.dart';

// class ReadEntryScreen extends StatelessWidget {
//   final String documentId;

//   const ReadEntryScreen({super.key, required this.documentId});

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Entry Detail'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: firestore.collection('entries').doc(documentId).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Entry not found'));
//           }

//           var entry = snapshot.data!;
//           var data = entry.data() as Map<String, dynamic>;
//           var title = data['title'] ?? 'No Title';
//           var description = data['description'] ?? 'No Description';
//           var images = data['images'] ?? [];
//           bool isImportant = data['isImportant'] ?? false;

//           String templateType;
//           if (title.startsWith('Outing:')) {
//             templateType = 'outing';
//           } else if (title.startsWith('Personal:')) {
//             templateType = 'personal';
//           } else if (title.startsWith('Work:')) {
//             templateType = 'work';
//           } else {
//             templateType = 'general';
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white, // Ensure text is visible
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     description,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Colors.white, // Ensure text is visible
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   if (templateType == 'outing') ...[
//                     Text(
//                       'Place',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['place'] ?? 'No Place',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Memories',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['memories'] ?? 'No Memories',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Reflection',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['reflection'] ?? 'No Reflection',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Date',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       (data['date'] as Timestamp?)?.toDate().toString() ?? 'No Date',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Images',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: images.map<Widget>((imageUrl) {
//                       return Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover);
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Icon(
//                         isImportant ? Icons.star : Icons.star_border,
//                         color: isImportant ? Colors.yellow : Colors.white,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Important Entry',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (templateType == 'outing') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => UpdateOutingEntryScreen(
//                               documentId: documentId,
//                               initialTitle: title,
//                               initialPlace: data['place'] ?? 'No Place',
//                               initialDescription: description,
//                               initialMemories: data['memories'] ?? 'No Memories',
//                               initialReflection: data['reflection'] ?? 'No Reflection',
//                               initialDate: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
//                               initialImages: List<String>.from(images),
//                               isImportant: isImportant,
//                             ),
//                           ),
//                         );
//                       } else {
//                         // Add logic for personal, work, and general templates here
//                       }
//                     },
//                     child: Text('Update Entry'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
