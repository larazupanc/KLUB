import 'package:flutter/material.dart';

class ObvestilaScreen extends StatelessWidget {
  const ObvestilaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Obvestila"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const Center(
        child: Text("Here are your notifications."),
      ),
    );
  }
}
