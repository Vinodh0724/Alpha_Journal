import 'package:apha_journal/screens/home/journal/adult_journal/adult_journal_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/kids_journal/kids_journal_entry_screen.dart';
import 'package:apha_journal/screens/home/journal/old_journal/old_journal_entry_screen.dart';
import 'package:apha_journal/screens/home/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgeBasedJournalTemplate extends StatefulWidget {
  const AgeBasedJournalTemplate({Key? key}) : super(key: key);

  @override
  _AgeBasedJournalTemplateState createState() => _AgeBasedJournalTemplateState();
}

class _AgeBasedJournalTemplateState extends State<AgeBasedJournalTemplate> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Get the current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }
    final userId = user.uid;

    // Fetch the user document from Firestore using the current user ID
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    // Check if the user has accepted the journal template
    _dialogShown = userDoc.data()?['acceptedJournalTemplate'] ?? false;

    if (!_dialogShown) {
      _determineJournalTemplate();
    } else {
      _navigateToJournalTemplate();
    }
  }

  Future<void> _determineJournalTemplate() async {
    try {
      // Get the current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }
      final userId = user.uid;

      // Fetch the user document from Firestore using the current user ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Get the user's age
      String? ageStr = userDoc.data()?['age'];
      if (ageStr == null) {
        // If age is not available, show a message and a button to navigate to the profile page
        _showProfileUpdateDialog();
      } else {
        int age = int.tryParse(ageStr) ?? 0;
        String template;

        if (age < 21) {
          template = 'Kids Journal';
        } else if (age < 60) {
          template = 'Adults Journal';
        } else {
          template = 'Elders Journal';
        }

        // Show the dialog with age and suitable template
        _showAgeDialog(ageStr, template);
      }
    } catch (e) {
      print("Error fetching user age: $e");
    }
  }

  void _showProfileUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Age', style: TextStyle(color: Colors.white)),
          content: Text(
            'Your age information is not available. Please update your age in the profile page.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _showAgeDialog(String age, String template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              contentTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.black, // Set dialog background color if needed
            title: Text('Journal Template', style: TextStyle(color: Colors.white)),
            content: Text('Your age is $age. The suitable journal template for you is $template.', style: TextStyle(color: Colors.white)),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _setUserAcceptedJournalTemplate();
                  Navigator.of(context).pop(); // Close the dialog
                  _navigateToJournalTemplate();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setUserAcceptedJournalTemplate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }
    final userId = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'acceptedJournalTemplate': true});
  }

  void _navigateToJournalTemplate() {
    // Get the current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }
    final userId = user.uid;

    // Fetch the user document from Firestore using the current user ID
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((userDoc) {
      // Get the user's age
      String? ageStr = userDoc.data()?['age'];
      if (ageStr != null) {
        int age = int.tryParse(ageStr) ?? 0;
        String template;

        if (age < 21) {
          template = 'Kids Journal';
        } else if (age < 60) {
          template = 'Adults Journal';
        } else {
          template = 'Elders Journal';
        }

        // Navigate directly to the respective journal template
        _navigateToJournalScreen(template);
      } else {
        // If age is not available, show a message and a button to navigate to the profile page
        _showProfileUpdateDialog();
      }
    }).catchError((error) {
      print("Error fetching user age: $error");
    });
  }

  void _navigateToJournalScreen(String template) {
    Widget targetScreen;

    if (template == 'Kids Journal') {
      targetScreen = KidsJournalScreen();
    } else if (template == 'Adults Journal') {
      targetScreen = AdultJournalScreen();
    } else {
      targetScreen = OldJournalScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
