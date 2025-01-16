import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:testni_app/screens/chat.dart';
import 'package:testni_app/screens/dogodki.dart';
import 'package:testni_app/screens/uporabniki.dart';
import 'screens/home_screen.dart';
import 'screens/koledar_screen.dart';
import 'screens/sestanki.dart';
import 'screens/registracija.dart';
import 'css/styles.dart'; // Import the AppStyles
import 'package:intl/intl_standalone.dart'; // Import initializeDateFormatting
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut();

  runApp(const MojaAplikacija());
}
class MojaAplikacija extends StatelessWidget {
  const MojaAplikacija({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KLUB PLUS',
      home: const LoginScreen(),
    );
  }
}

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
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      String userEmail = userCredential.user!.email!;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        String role = userDoc.get('role') ?? 'Unknown';
        print('User role from Firestore: $role');
        setState(() {
          _message = "Login successful as $role!";
        });

        // Navigate to NavigationController first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationController(role: role)),
        );
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
      backgroundColor: Color(0xFAFAFAFA),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppStyles.generalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Dobrodošli v KLUB PLUS",
                  textAlign: TextAlign.center,
                  style: AppStyles.headerTitle,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "@uporabniskoime",
                    hintStyle: AppStyles.defaultDayTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Geslo",
                    hintStyle: AppStyles.defaultDayTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    suffixIcon: Icon(Icons.visibility_off, color: AppStyles.iconColorKoledar),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.iconBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    "Prijava",
                    style: AppStyles.calendarDayTextStyle,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Implement forgot password functionality
                  },
                  style: AppStyles.greenTextButton, // Match button style
                  child: const Text("Pozabljeno geslo?"),
                ),
                const SizedBox(height: 10),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationTap;

  const CustomHeader({super.key, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "KLUB+",
        style: TextStyle(
          fontSize: 22.0,
          color: Color(0xFF004d40),
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              const Icon(Icons.notifications_none_sharp, size: 25, color: Colors.black),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
class NavigationController extends StatefulWidget {
  final String role;

  const NavigationController({super.key, required this.role});

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    // Initialize pages and nav items based on user role
    if (widget.role == 'Predsednik') {
      _pages = [
        HomeScreen(),
        KoledarScreen(),
        SestankiScreen(),
        NekiScreen(),
        UserListScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Domov'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Koledar'),
        BottomNavigationBarItem(icon: Icon(Icons.cases_sharp), label: 'Sestanki'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_bar), label: 'Dogodki'),
        BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Registracija'),
      ];
    } else {
      _pages = [
        HomeScreen(),
        KoledarScreen(),
        NekiScreen(),
        SestankiScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Domov'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Koledar'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_bar), label: 'Dogodki'),
        BottomNavigationBarItem(icon: Icon(Icons.cases_sharp), label: 'Sestanki'),
      ];
    }

    // Navigate to GroupChatScreen after a short delay (you can change this as needed)
    Future.delayed(Duration(seconds: 2), () {
      String userEmail = FirebaseAuth.instance.currentUser!.email!; // Get the current user's email

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(userEmail: userEmail),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF004d40),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}
