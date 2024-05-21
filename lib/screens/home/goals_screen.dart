import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      body: Center(
        child: Text('Goal Screen Content'),
      ),
    );
  }
}
