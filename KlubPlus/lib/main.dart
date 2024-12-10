import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testni_app/screens/dogodki.dart';
import 'screens/home_screen.dart';
import 'screens/koledar_screen.dart';
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

// LoginScreen handles authentication and redirects to NavigationController
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to main app after login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationController()),
      );
    } catch (e) {
      setState(() {
        _message = "Ne veljaven profil";
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

// NavigationController remains unchanged
class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    KoledarScreen(),
    NekiScreen(),
    Center(child: Text('Nastavitve Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Koledar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Dogodki'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Nastavitve'),
        ],
      ),
    );
  }
}
