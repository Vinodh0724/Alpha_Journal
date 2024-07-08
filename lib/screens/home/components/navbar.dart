import 'package:apha_journal/screens/home/goals/goals_screen.dart';
import 'package:apha_journal/screens/home/journal/adult_journal/adult_journal_entry_screen.dart';
import 'package:apha_journal/screens/home/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:apha_journal/screens/home/home_screen.dart';
import 'package:apha_journal/shop/shop_screen.dart'; 
import 'package:apha_journal/shop/my_stickers_screen.dart'; 



class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 1; // Index for Journal screen

  static final  List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Home screen
    const AdultJournalScreen(), // Journal screen (Your existing screen)
    const GoalsScreen(), // Goals screen
    const ProfilePage(), // Profile screen
    ShopScreen(), // Shop screen (New screen)
    MyStickersScreen(), // My Stickers screen (New screen)


    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
              BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2),
            label: 'My Stickers', 
          ),
    
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
