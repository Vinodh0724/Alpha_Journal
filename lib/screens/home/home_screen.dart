import 'package:apha_journal/screens/home/drawer.dart';
import 'package:apha_journal/screens/home/goals/goals_screen.dart';
import 'package:apha_journal/screens/home/journal/age_based_journal_template.dart';
import 'package:apha_journal/screens/home/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/sign_in_bloc/sign_in_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNotification = false; // Flag to control the red dot notification

  @override
  void initState() {
    super.initState();
    // Call a function to check if user's age is empty
    _checkUserAge();
  }

  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  // Function to check if user's age is empty
  void _checkUserAge() async {
    // Get current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Retrieve user document from Firestore using the user's ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Check if age field is empty
      if (userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)['age'] == null) {
        setState(() {
          _showNotification = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(userRepository: FirebaseUserRepo()),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  context.read<SignInBloc>().add(const SignOutRequired());
                },
              ),
            ],
          ),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBox("Journal", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgeBasedJournalTemplate(),
                    ),
                  );
                }),
                _buildBox("Goals", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalsScreen(),
                    ),
                  );
                }),
                _buildProfileBox(context),
              ],
            ),
          ),
          drawer: MyDrawer(
            onProfileTap: () => goToProfilePage(context),
          ),
        );
      },
    );
  }

  Widget _buildBox(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        color: Color.fromARGB(255, 92, 68, 10),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBox(BuildContext context) {
    return GestureDetector(
      onTap: () => goToProfilePage(context),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            color: Color.fromARGB(255, 92, 68, 10),
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          if (_showNotification)
            Positioned(
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 15,
                  minHeight: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
