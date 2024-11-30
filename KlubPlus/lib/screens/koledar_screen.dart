import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:testni_app/css/styles.dart'; // Import your styles

class KoledarScreen extends StatefulWidget {
  const KoledarScreen({super.key});

  @override
  _KoledarScreenState createState() => _KoledarScreenState();
}

class _KoledarScreenState extends State<KoledarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Koledar",
          style: AppStyles.headerTitle,
        ),
        backgroundColor: AppStyles.headerBackgroundColor,
        elevation: 0, // Flat header style
        iconTheme: const IconThemeData(color: AppStyles.iconColor),
      ),
      body: Padding(
        padding: AppStyles.generalPadding,
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Update the calendar's focused day
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppStyles.highlightColor,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppStyles.calendarDayTextStyle,
                selectedDecoration: BoxDecoration(
                  color: AppStyles.selectedDayColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppStyles.calendarDayTextStyle,
                defaultTextStyle: AppStyles.defaultDayTextStyle,
                weekendTextStyle: AppStyles.weekendDayTextStyle,
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppStyles.headerTextStyle,
                leftChevronIcon: Icon(Icons.chevron_left, color: AppStyles.iconColorKoledar),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppStyles.iconColorKoledar),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Selected Date: ${_selectedDay.toLocal()}".split(' ')[0],
              style: AppStyles.selectedDateTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
