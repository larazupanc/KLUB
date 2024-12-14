import 'package:flutter/material.dart';

class AppStyles {
  static const Color backgroundColor = Colors.white;
  static const EdgeInsets generalPadding = EdgeInsets.all(16.0);
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF004d40), // Dark green color
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF004d40), // Dark green color
  );

  // Subtitle Style
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: Color(0xFF004d40), // Dark green color
  );

  // Link Button Style
  static final ButtonStyle greenTextButton = TextButton.styleFrom(
    foregroundColor: Color(0xFF004d40),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );

  // Card Style
  static final BoxDecoration cardBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2), // Shadow color
        spreadRadius: 2,
        blurRadius: 6,
        offset: const Offset(0, 3), // Shadow position
      ),
    ],
  );

  // Icon Style
  static const Color iconColor = Colors.lightGreenAccent; // Icon color for the circle
  static const Color iconColorKoledar = Color(0xFF004d40);  // Icon color for the circle
  static const Color iconBackgroundColor = Color(0xFF004d40); // Dark green circle

  // Navbar Styles
  static const Color navBarBackground = Colors.white; // Background color of the navbar
  static const Color selectedNavBarItem = Color(0xFF004d40); // Selected icon/text color
  static const Color unselectedNavBarItem = Colors.grey; // Unselected icon/text color

  static BoxDecoration navBarDecoration = BoxDecoration(
    color: Colors.white,


    borderRadius: BorderRadius.circular(24.0), // Rounded edges
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 10.0,
        offset: Offset(0, 4), // Shadow position
      ),
    ],
  );

  static const TextStyle navBarItemTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF004d40), // Dark green color

  );
  static const Color highlightColor = Color(0xFF004d40); // Dark green for today
  static const Color selectedDayColor = Color(0xFF1976D2); // Blue for selected day
  static const Color weekendTextColor = Colors.red;
  static const Color defaultDayTextColor = Colors.black;

  // Calendar Text Styles
  static const TextStyle calendarDayTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle defaultDayTextStyle = TextStyle(
    color: defaultDayTextColor,
  );
  static const TextStyle weekendDayTextStyle = TextStyle(
    color: weekendTextColor,
    fontWeight: FontWeight.bold,
  );

  // Selected Date Text Style
  static const TextStyle selectedDateTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF004d40), // Dark green color
  );

  // Header Style
  static const Color headerBackgroundColor = Colors.white;
  static const TextStyle headerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF004d40), // Dark green color
  );
  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF004d40), // Dark green color
  );
}
