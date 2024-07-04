import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewGoalsScreen extends StatelessWidget {
  final String goalId;

  const ViewGoalsScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Goal'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('goals').doc(goalId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Goal not found.'));
          }

          var goalData = snapshot.data!.data() as Map<String, dynamic>;
          var title = goalData['title'];
          var startDate = DateTime.parse(goalData['startDate']);
          var endDate = DateTime.parse(goalData['endDate']);
          var isCompleted = goalData['isCompleted'];
          var reminderTime = goalData['reminderTime'] != null
              ? _parseTime(goalData['reminderTime'])
              : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: $title',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(isCompleted ? Icons.check_circle : Icons.cancel,
                            color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'Completed: ${isCompleted ? 'Yes' : 'No'}',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (reminderTime != null)
                      Row(
                        children: [
                          Icon(Icons.alarm, color: Colors.white70),
                          SizedBox(width: 8),
                          Text(
                            'Reminder Time: ${reminderTime.format(context)}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final format = RegExp(r'(\d{2}):(\d{2})');
    final match = format.firstMatch(time);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      throw FormatException("Invalid time format");
    }
  }
}
