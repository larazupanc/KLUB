import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:testni_app/screens/dogodki.dart';
import 'screens/home_screen.dart';
import 'screens/koledar_screen.dart';
import 'screens/sestanki.dart';
import 'screens/registracija.dart';
import 'css/styles.dart'; // Import the AppStyles

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Ensure the user is logged out at startup
  await FirebaseAuth.instance.signOut();

  runApp(const MojaAplikacija());
}

class MojaAplikacija extends StatelessWidget {
  const MojaAplikacija({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacija za vnos zaposlenih',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

      // Fetch user role from Firestore
      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        String role = userDoc.get('role') ?? 'Unknown'; // Safely fetch role field
        print('User role from Firestore: $role'); // Debugging Firestore value

        setState(() {
          _message = "Login successful as $role!";
        });

        // Navigate to NavigationController with the role
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppStyles.generalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Dobrodošli v KLUB+",
                  textAlign: TextAlign.center,
                  style: AppStyles.headerTitle, // Use headerTitle from AppStyles
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "@username",
                    hintStyle: AppStyles.defaultDayTextStyle, // Match with text styling
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: AppStyles.defaultDayTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: Icon(Icons.visibility_off,
                        color: AppStyles.iconColorKoledar),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.iconBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    "Prijava",
                    style: AppStyles.calendarDayTextStyle, // Use consistent text styling
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

class NavigationController extends StatefulWidget {
  final String role; // Accept the role
  const NavigationController({super.key, required this.role});

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  // Define pages and items for different roles
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    if (widget.role == 'Predsednik') {
      _pages = [
        HomeScreen(),
        KoledarScreen(),
        SestankiScreen(),
        UserRegistrationScreen(),
        NekiScreen()
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
        SestankiScreen(),
        NekiScreen()
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Domov'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Koledar'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_bar), label: 'Dogodki'),
        BottomNavigationBarItem(icon: Icon(Icons.cases_sharp), label: 'Sestanki'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
