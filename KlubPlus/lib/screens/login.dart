import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testni_app/css/styles.dart'; // Import your styles

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = "";

  Future<void> _login() async {
    try {
      // Sign in the user
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Fetch user role from Firestore
      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // The collection containing user info
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role']; // Fetch the 'role' field from Firestore

        setState(() {
          _message = "Login successful as $role!";
        });

        // Navigate based on role
        if (role == 'admin') {
          // Admin route (example: Admin dashboard screen)
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else {
          // Normal user route (example: User dashboard screen)
          Navigator.pushReplacementNamed(context, '/userHome');
        }
      } else {
        setState(() {
          _message = "User document does not exist!";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Login failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: AppStyles.headerTitle,
        ),
        backgroundColor: AppStyles.headerBackgroundColor,
        elevation: 0, // Flat header style
        iconTheme: const IconThemeData(color: AppStyles.iconColor),
      ),
      backgroundColor: Color(0xFAFAFAFA),
      body: Padding(
        padding: AppStyles.generalPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(),
              child: const Text("Log In"),
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
