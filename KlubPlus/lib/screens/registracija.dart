import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for saving data
import 'package:testni_app/css/styles.dart'; // Import your styles

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

  final List<String> _roles = ["Predsednik", "Aktivist", "Tajnica", "Social Media Manager"];

  Future<void> _registerUser() async {
    try {
      if (_selectedRole == null) {
        setState(() {
          _message = "Izberi vlogo.";
        });
        return;
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
      });

      setState(() {
        _message = "uspesn!";
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
        _message = " failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registracija novega uporabnika",
          style: AppStyles.headerTitle,
        ),
        backgroundColor: AppStyles.headerBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: AppStyles.generalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Role"),
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
                color: _message.contains("failed") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
