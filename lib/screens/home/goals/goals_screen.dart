import 'package:apha_journal/screens/home/goals/add_goals_screen.dart';
import 'package:apha_journal/screens/home/goals/goal_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  void _navigateToAddGoalScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalScreen(),
      ),
    );
  }

  void _navigateToGoalsHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalsHistoryScreen(),
      ),
    );
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete goal: $e')),
      );
    }
  }

  Future<void> _toggleGoalCompletion(String goalId, bool isCompleted) async {
    try {
      await _firestore.collection('goals').doc(goalId).update({'isCompleted': !isCompleted});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update goal: $e')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Goals'),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _navigateToGoalsHistoryScreen,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 107, 83, 74)),
            ),
            child: Text(
              'View Completed Goals',
              style: TextStyle(color: Color.fromARGB(255, 253, 168, 0)),
            ),
          ),
          SizedBox(height: 16.0), // Add space between the completed goal button and the list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('goals').where('userId', isEqualTo: user?.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No goals yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var goals = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    var goal = goals[index];
                    var isCompleted = goal['isCompleted'] as bool;
                    if (isCompleted) return SizedBox.shrink(); // Hide completed goals from this list

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
                            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Start Date: ${startDate.toLocal().toString().split(' ')[0]} \nEnd Date: ${endDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                              onPressed: () => _toggleGoalCompletion(goal.id, isCompleted),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteGoal(goal.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToAddGoalScreen,
      child: Icon(Icons.add),
    ),
  );
}

}
