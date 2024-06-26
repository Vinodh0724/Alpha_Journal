import 'package:apha_journal/screens/home/goals/goals_screen.dart';
import 'package:apha_journal/screens/home/home_screen.dart';
import 'package:apha_journal/screens/home/journal/kids_journal/try%20journal.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Profile Page'),
      ),
      body: const Center(
        child: Text('Profile Page'),
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
              MaterialPageRoute(builder: (context) =>  JournalScreen()),
              );
            }
          ),
          GButton(
            icon: Icons.bookmark,
            text:'Goals',
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  GoalsScreen()),
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