import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for saving data
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:testni_app/css/styles.dart';
import 'package:testni_app/main.dart';
import 'package:testni_app/screens/obvestilascreen.dart'; // Import your styles

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({Key? key}) : super(key: key);

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  String _message = "";

  final List<String> _roles = [
    "Predsednik",
    "Aktivist",
    "Tajnica",
    "Social Media Manager"
  ];

  Future<void> _registerUser() async {
    try {
      if (_selectedRole == null) {
        setState(() {
          _message = "Izberi vlogo.";
        });
        return;
      }

      if (_passwordController.text.isEmpty) {
        setState(() {
          _message = "Vnesi geslo.";
        });
        return;
      }

      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid) // Use UID as the document ID
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'created_at': FieldValue.serverTimestamp(), // Store timestamp
      });

      setState(() {
        _message = "Uporabnik uspešno registriran!";
      });

      // Clear the fields
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedRole = null;
      });
    } catch (e) {
      setState(() {
        _message = "Registracija ni uspela: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ObvestilaScreen()),
          );
        },
      ),
      backgroundColor: Color(0xFAFAFAFA),
      body: Padding(
        padding: AppStyles.generalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Ime"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Geslo"),
              obscureText: true, // Hide password text
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Vloga"),
              value: _roles.contains(_selectedRole) ? _selectedRole : null,
              items: _roles
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text("Registriraj"),
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _message.contains("ni uspela") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
