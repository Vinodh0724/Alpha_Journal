import 'dart:io';

import 'package:apha_journal/app.dart';
import 'package:apha_journal/local_notofications.dart';
import 'package:apha_journal/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyA3ulDyLMRnN31H7dveclg9O6l78VFewaA",
              appId: "1:327495814790:android:e0b59822a24426611acb07",
              messagingSenderId: "327495814790",
              projectId: "alpha-journal-app"),
        )
      : await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  tz.initializeTimeZones;
  runApp(MyApp(FirebaseUserRepo()));
}
