import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
      ),
      body: Center(
        child: Text('Journal Screen Content'),
      ),
    );
  }
}
