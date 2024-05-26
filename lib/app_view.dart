import 'package:apha_journal/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:apha_journal/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apha_journal/screens/auth/welcome_screen.dart';
import 'package:apha_journal/screens/home/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Alpha Journal',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
              background: Color.fromARGB(255, 0, 0, 0),
              onBackground: Color.fromARGB(255, 0, 0, 0),
              primary: Color.fromRGBO(30, 255, 0, 1),
              onPrimary: Colors.black,
              secondary: Color.fromRGBO(244, 143, 177, 1),
              onSecondary: Color.fromARGB(255, 0, 0, 0),
              tertiary: Color.fromRGBO(255, 204, 128, 1),
              error: Colors.red,
              outline: Color(0xFF424242)),
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return BlocProvider(
              create: (context) => SignInBloc(
                userRepository: context.read<AuthenticationBloc>().userRepository
              ),
              child: const HomeScreen(),
            );
          } else {
            return const WelcomeScreen();
          }
        }));
  }
}
