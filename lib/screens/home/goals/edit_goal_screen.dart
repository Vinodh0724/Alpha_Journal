import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditGoalScreen extends StatefulWidget {
  final String goalId;

  const EditGoalScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  _EditGoalScreenState createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 30));
  TimeOfDay? _reminderTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchGoalDetails();
  }

  Future<void> _fetchGoalDetails() async {
    final DocumentSnapshot goalSnapshot =
        await _firestore.collection('goals').doc(widget.goalId).get();
    if (goalSnapshot.exists) {
      final Map<String, dynamic> goalData =
          goalSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _titleController.text = goalData['title'];
        _startDate = DateTime.parse(goalData['startDate']);
        _endDate = DateTime.parse(goalData['endDate']);
        if (goalData['reminderTime'] != null) {
          final List<String> timeParts = goalData['reminderTime'].split(':');
          _reminderTime = TimeOfDay(
              hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        }
      });
    }
  }

  Future<void> _saveGoal() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _titleController.text.isNotEmpty) {
      await _firestore.collection('goals').doc(widget.goalId).update({
        'title': _titleController.text,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'reminderTime': _reminderTime != null
            ? "${_reminderTime!.hour}:${_reminderTime!.minute}"
            : null,
      });
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Goal'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveGoal,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900], // Set background color
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Title',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  hintText: 'Enter goal title',
                  hintStyle:
                      TextStyle(color: Colors.white54), // Set hint text color
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Set border color
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Start Date',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Text(_startDate.toString().split(' ')[0],
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'End Date',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Text(_endDate.toString().split(' ')[0],
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Reminder Time',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => _selectTime(context),
                child: Text(
                  _reminderTime != null
                      ? _reminderTime!.format(context)
                      : 'Select time',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
