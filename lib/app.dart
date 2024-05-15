import 'package:apha_journal/app_view.dart';
import 'package:apha_journal/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class MyApp extends StatelessWidget {
  final UserRepository userReposotory;
  const MyApp(this.userReposotory, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(
        userRepository: userReposotory
      ),
      child: const MyAppView(),
    );
  }
}
