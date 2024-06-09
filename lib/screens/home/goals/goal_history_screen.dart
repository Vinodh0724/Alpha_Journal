import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsHistoryScreen extends StatefulWidget {
  const GoalsHistoryScreen({Key? key}) : super(key: key);

  @override
  _GoalsHistoryScreenState createState() => _GoalsHistoryScreenState();
}

class _GoalsHistoryScreenState extends State<GoalsHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete goal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('goals')
            .where('userId', isEqualTo: user?.uid)
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No completed goals yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var goals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              var goal = goals[index];
              DateTime startDate = DateTime.parse(goal['startDate']);
              DateTime endDate = DateTime.parse(goal['endDate']);

              return Card(
                color: Colors.grey[850],
                child: ListTile(
                  title: Text(
                    goal['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    'Start Date: ${startDate.toLocal().toString().split(' ')[0]} \nEnd Date: ${endDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteGoal(goal.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
