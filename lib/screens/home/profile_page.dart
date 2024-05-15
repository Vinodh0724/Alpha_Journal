

import 'package:apha_journal/screens/home/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override 
  State<ProfilePage> createState() => _ProfileState();
  
}

class _ProfileState extends State<ProfilePage>{
  final currentUser = FirebaseAuth.instance.currentUser!;
  
  

  Future<void> editFiled(String field) async{

  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[3],
      appBar: AppBar(
        title:  const Text('Profile Page'),
        
      ),
      body: ListView(
       children: [ 
         const SizedBox(height: 50),

        const Icon(
          Icons.person,
          size: 72,
        ),
        const SizedBox(height: 10),

        Text(
          currentUser.email!,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(height: 50),

        Padding(
          padding: const EdgeInsets.only(left:25.0),
          child: Text( 
            'My Details',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),

        MyTextBox(
          text: 'Empty', 
          sectionName: 'Username',
          onPressed: () => editFiled('Username'),
        ),

        MyTextBox(
          text: 'Empty', 
          sectionName: 'Birth of date',
          onPressed: () => editFiled('Birth of date'),
        ),

        MyTextBox(
          text: 'Empty', 
          sectionName: 'Profession',
          onPressed: () => editFiled('Profession'),
        ),

        MyTextBox(
          text: 'Empty', 
          sectionName: 'Bio',
          onPressed: () => editFiled('Bio'),
        ),

       
      ], 
      ),
    );
  }
}