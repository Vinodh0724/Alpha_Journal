import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_goals_screen.dart'; // Import ViewGoalsScreen


class GoalsHistoryScreen extends StatefulWidget {
  const GoalsHistoryScreen({super.key});

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

    void _navigateToViewGoalScreen(String goalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGoalsScreen(goalId: goalId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('goals')
            .where('userId', isEqualTo: user?.uid)
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    'Start Date: ${startDate.toLocal().toString().split(' ')[0]} \nEnd Date: ${endDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteGoal(goal.id),
                  ),
                                      onTap: () => _navigateToViewGoalScreen(goal.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
