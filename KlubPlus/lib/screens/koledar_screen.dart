import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testni_app/css/styles.dart'; // Import your styles

class KoledarScreen extends StatefulWidget {
  const KoledarScreen({super.key});

  @override
  _KoledarScreenState createState() => _KoledarScreenState();
}

class _KoledarScreenState extends State<KoledarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {}; // Store events for marking

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final Map<DateTime, List<String>> events = {};

    // Fetch dogodki (events)
    final dogodkiSnapshot = await FirebaseFirestore.instance.collection('dogodki').get();
    for (var doc in dogodkiSnapshot.docs) {
      final data = doc.data();
      final eventDate = (data['datum'] as Timestamp).toDate();
      final dateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (!events.containsKey(dateOnly)) {
        events[dateOnly] = [];
      }
      events[dateOnly]!.add(data['naziv'] ?? 'Unnamed Event');
    }

    // Fetch sestanki (meetings)
    final sestankiSnapshot = await FirebaseFirestore.instance.collection('sestanki').get();
    for (var doc in sestankiSnapshot.docs) {
      final data = doc.data();
      final meetingDate = (data['datum'] as Timestamp).toDate();
      final dateOnly = DateTime(meetingDate.year, meetingDate.month, meetingDate.day);

      if (!events.containsKey(dateOnly)) {
        events[dateOnly] = [];
      }
      events[dateOnly]!.add(data['naziv'] ?? 'Unnamed Meeting');
    }

    setState(() {
      _events = events;
      print("Loaded events and meetings: $_events"); // Debugging output
    });
  }

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
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                print("Checking events for $normalizedDay: ${_events[normalizedDay]}"); // Debugging output
                return _events[normalizedDay] ?? [];
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
                markersAutoAligned: false, // Disable auto-alignment for better size control
                markerSizeScale: 0.4, // Make markers the same size as the day circle
                markerDecoration: BoxDecoration(
                  color: Colors.green, // Marker color
                  shape: BoxShape.circle,
                ),
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
            const SizedBox(height: 16.0),
            Expanded(
              child: _events.containsKey(_selectedDay)
                  ? ListView.builder(
                itemCount: _events[_selectedDay]?.length ?? 0,
                itemBuilder: (context, index) {
                  final event = _events[_selectedDay]![index];
                  return Card(
                    child: ListTile(
                      title: Text(event),
                    ),
                  );
                },
              )
                  : const Center(child: Text('No events or meetings found for this day.')),

            )
          ],
        ),
      ),
    );
  }

  /// Method to get Firestore events for the selected day
  Stream<QuerySnapshot> _getEventsForSelectedDay() {
    // Start of the day
    final startOfDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    // End of the day
    final endOfDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59, 59);

    // Query Firestore for events within the selected day
    return FirebaseFirestore.instance
        .collectionGroup('dogodki_sestanki') // Use collectionGroup if you combine collections
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots();
  }
}
