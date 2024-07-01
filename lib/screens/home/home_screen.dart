import 'package:apha_journal/screens/home/drawer.dart';
import 'package:apha_journal/screens/home/goals/goals_screen.dart';
import 'package:apha_journal/screens/home/journal/age_based_journal_template.dart';
import 'package:apha_journal/screens/home/profile_page.dart';
import 'package:apha_journal/shop/my_stickers_screen.dart';
import 'package:apha_journal/shop/shop_screen.dart';
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
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
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

  void _checkUserAge() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
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
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<SignInBloc>().add(const SignOutRequired());
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildBox('Journal', Icons.book, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgeBasedJournalTemplate(),
                    ),
                  );
                }),
                _buildBox('Goals', Icons.flag, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalsScreen(),
                    ),
                  );
                }),
                _buildBox('Shop', Icons.shopping_cart, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopScreen(),
                    ),
                  );
                }),
                _buildBox('My Stickers', Icons.sticky_note_2, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyStickersScreen(),
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

  Widget _buildBox(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
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
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Profile',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          if (_showNotification)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
