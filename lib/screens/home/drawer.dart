import 'package:apha_journal/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:apha_journal/screens/home/my_list_tile.dart';
import 'package:apha_journal/screens/home/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  
  final void Function()? onProfileTap;
  const MyDrawer({super.key, required this.onProfileTap});

  @override 
  Widget build(BuildContext context){
    return Drawer(
      backgroundColor: Colors.grey[900],
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [ 
           const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            )
          ),
          MyListTile(
            icon: Icons.home, 
            text: 'H O M E',
            onTap: () => Navigator.pop(context),
          ),
          MyListTile(
            icon: Icons.person, 
            text: 'P R O F I L E',
            onTap: onProfileTap,
          ), 
          MyListTile(
            icon: Icons.support, 
            text: 'S U P P O R T',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportPage()),
            ),
          ),
          ],),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout, 
              text: 'L O G O U T',
              onTap: () {
                          context.read<SignInBloc>().add(const SignOutRequired());
                        },
            ),
          ),
        ],
      ),
    );
  }
}
