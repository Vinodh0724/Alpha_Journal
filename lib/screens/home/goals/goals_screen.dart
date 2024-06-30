import 'package:apha_journal/screens/home/goals/add_goals_screen.dart';
import 'package:apha_journal/screens/home/goals/goal_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apha_journal/screens/home/goals/view_goals_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  int userPoints = 0;
  int completedGoalsToday = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _checkCompletedGoalsToday();
  }

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

  void _navigateToViewGoalScreen(String goalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGoalsScreen(goalId: goalId),
      ),
    );
  }

  Future<void> _loadUserPoints() async {
    if (user == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
    setState(() {
      userPoints = userDoc['points'] ?? 0;
    });
  }

  Future<void> _checkCompletedGoalsToday() async {
    if (user == null) return;

    QuerySnapshot completedGoals = await _firestore
        .collection('goals')
        .where('userId', isEqualTo: user!.uid)
        .where('isCompleted', isEqualTo: true)
        .where('completedDate', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 1)))
        .get();

    setState(() {
      completedGoalsToday = completedGoals.docs.length;
    });
  }

  Future<void> _toggleGoalCompletion(String goalId, bool isCompleted) async {
    if (user == null) return;

    try {
      await _firestore.collection('goals').doc(goalId).update({
        'isCompleted': !isCompleted,
        'completedDate': !isCompleted ? DateTime.now() : null,
      });

      if (!isCompleted && completedGoalsToday < 10) {
        setState(() {
          userPoints += 10;
          completedGoalsToday++;
        });

        await _firestore.collection('users').doc(user!.uid).update({
          'points': userPoints,
        });
      }

      _loadUserPoints();
      _checkCompletedGoalsToday();
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Points: $userPoints',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _navigateToGoalsHistoryScreen,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
              ),
              child: Text(
                'View Completed Goals',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16.0),
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
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }

                  var goals = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      var goal = goals[index];
                      var isCompleted = goal['isCompleted'] as bool;
                      if (isCompleted) return SizedBox.shrink();

                      DateTime startDate = DateTime.parse(goal['startDate']);
                      DateTime endDate = DateTime.parse(goal['endDate']);

                      return Card(
                        color: Colors.teal[200],
                        child: ListTile(
                          title: Text(
                            goal['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Start Date: ${startDate.toLocal().toString().split(' ')[0]} \nEnd Date: ${endDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: Colors.black,
                                ),
                                onPressed: () => _toggleGoalCompletion(goal.id, isCompleted),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.black),
                                onPressed: () => _deleteGoal(goal.id),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToViewGoalScreen(goal.id),
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
        backgroundColor: Colors.teal,
      ),
    );
  }
}
