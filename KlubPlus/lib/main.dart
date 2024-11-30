import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/koledar_screen.dart';
import 'package:testni_app/css/styles.dart';


void main() {
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
      home: const NavigationController(), // Root widget for navigation
    );
  }
}
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
    Center(child: Text('Obvestila Page')),
    Center(child: Text('Nastavitve Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: AppStyles.navBarDecoration, // Rounded navbar styling
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Transparent background
            elevation: 0, // Remove shadow for the BottomNavigationBar
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: AppStyles.selectedNavBarItem, // Highlighted item color
            unselectedItemColor: AppStyles.unselectedNavBarItem, // Dim inactive items
            selectedLabelStyle: AppStyles.navBarItemTextStyle,
            unselectedLabelStyle: AppStyles.navBarItemTextStyle,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Koledar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Dogodki',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Obvestila',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Nastavitve',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
