//import 'package:apha_journal/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:apha_journal/screens/home/drawer.dart';
import 'package:apha_journal/screens/home/goals_screen.dart';
import 'package:apha_journal/screens/home/journal_entry_screen.dart';
import 'package:apha_journal/screens/home/profile_page.dart';
import 'package:apha_journal/screens/home/user_profile_screen.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void goToProfilePage(BuildContext context){
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home screen',
        ),
      ),
      body:const Column(
        children: [
          // Your welcome message
          Padding(
            padding:  EdgeInsets.all(16.0),
            child: Text(
              'Welcome, Alpha Journal is currently in development. Stay tuned for the next update!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Add your other widgets below
          // Drawer and bottomNavigationBar
          // ...
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
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
