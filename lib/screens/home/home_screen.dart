import 'package:apha_journal/screens/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:apha_journal/screens/home/goals_screen.dart';
import 'package:apha_journal/screens/home/journal_entry_screen.dart';
import 'package:apha_journal/screens/home/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Make key parameter required

  

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void goToProfilePage(BuildContext context){
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const JournalScreen(),
    const GoalsScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome, Alpha Journal is currently in development. Stay tuned for the next update!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
