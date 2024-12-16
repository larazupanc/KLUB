import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uporabniki"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching users"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['name'] ?? "Unknown";
              final role = user['role'] ?? "Unknown";
              final email = user['email'] ?? "Unknown";

              return ListTile(
                leading: CircleAvatar(
                  child: Text(name[0].toUpperCase()),
                ),
                title: Text(name),
                subtitle: Text("Role: $role\nEmail: $email"),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegistrationForm(context),
        backgroundColor: const Color(0xFF004d40),
        child: const Icon(Icons.add, color: Colors.lightGreenAccent),
      ),
    );
  }

  void _showRegistrationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: const UserRegistrationWidget(),
        );
      },
    );
  }
}

class UserRegistrationWidget extends StatefulWidget {
  const UserRegistrationWidget({Key? key}) : super(key: key);

  @override
  _UserRegistrationWidgetState createState() => _UserRegistrationWidgetState();
}

class _UserRegistrationWidgetState extends State<UserRegistrationWidget> {
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

      // Close the modal
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _message = "Registracija ni uspela: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          obscureText: true,
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
    );
  }
}
