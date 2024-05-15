import 'package:apha_journal/screens/home/goals_screen.dart';
import 'package:apha_journal/screens/home/home_screen.dart';
import 'package:apha_journal/screens/home/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Page'),
      ),
      body: const Center(
        child: Text('Journal Page'),
      ),
      bottomNavigationBar: Container(
      color: Colors.black,
      child:  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: GNav(
        backgroundColor: Colors.black,
        color: Colors.white,
        activeColor: const Color.fromARGB(255, 255, 255, 255),
        tabBackgroundColor: const Color.fromARGB(255, 91, 91, 91),
        gap: 8,
        padding: const EdgeInsets.all(16),
        tabs: [
          GButton(
            icon: Icons.home,
            text:'Home',
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          ),
          GButton(
            icon: Icons.book,
            text:'Journal',
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JournalScreen()),
              );
            }
          ),
          GButton(
            icon: Icons.bookmark,
            text:'Goals',
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
            }
          ),
          GButton(
            icon: Icons.person,
            text:'Profile',
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }
          ),
        ],
      ),
    ),
    ),
    );
  }
}