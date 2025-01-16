import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testni_app/css/styles.dart';
import 'package:testni_app/main.dart';
import 'package:testni_app/screens/obvestilascreen.dart';

class KoledarScreen extends StatefulWidget {
  const KoledarScreen({super.key});
  @override
  _KoledarScreenState createState() => _KoledarScreenState();
}

class _KoledarScreenState extends State<KoledarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<String, dynamic>? _selectedEventDetails;

  // New variables for counters
  int _sestankiCount = 0;
  int _dogodkiCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final sestankiSnapshot =
    await FirebaseFirestore.instance.collection('sestanki').get();
    final dogodkiSnapshot =
    await FirebaseFirestore.instance.collection('dogodki').get();

    setState(() {
      _sestankiCount = sestankiSnapshot.size;
      _dogodkiCount = dogodkiSnapshot.size;
    });
  }
  Future<void> _loadEvents() async {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};
    final dogodkiSnapshot =
    await FirebaseFirestore.instance.collection('dogodki').get();
    for (var doc in dogodkiSnapshot.docs) {
      final data = doc.data();
      final eventDate = (data['datum'] as Timestamp).toDate();
      final dateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (!events.containsKey(dateOnly)) {
        events[dateOnly] = [];
      }
      events[dateOnly]!.add({
        'type': 'Dogodek',
        'naziv': data['naziv'] ?? 'Unnamed Event',
        'opis': data['opis'] ?? '',
        'kategorija': data['kategorija'] ?? '',
      });
    }

    final sestankiSnapshot =
    await FirebaseFirestore.instance.collection('sestanki').get();
    for (var doc in sestankiSnapshot.docs) {
      final data = doc.data();
      final meetingDate = (data['datum'] as Timestamp).toDate();
      final dateOnly =
      DateTime(meetingDate.year, meetingDate.month, meetingDate.day);

      if (!events.containsKey(dateOnly)) {
        events[dateOnly] = [];
      }
      events[dateOnly]!.add({
        'type': 'Sestanek',
        'naziv': data['naziv'] ?? 'Unnamed Meeting',
        'dnevni_red': data['dnevni_red'] ?? '',
      });
    }

    setState(() {
      _events = events;
      print("Loaded all events and meetings: $_events");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ObvestilaScreen()),
          );
        },
      ),
      backgroundColor: Color(0xFAFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(), // Optional: Smooth scrolling effect
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCounter('Sestankov v 2025', _sestankiCount, Icons.meeting_room),
                      _buildCounter('Dogodkov v 2025', _dogodkiCount, Icons.celebration),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedEventDetails = null;
                          _openEventDetails(selectedDay);
                        });
                      },
                      eventLoader: (day) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        return _events[normalizedDay] ?? [];
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppStyles.selectedDayColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: AppStyles.headerTextStyle,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return null;

                          final dogodki = events
                              .where((e) => (e as Map<String, dynamic>)['type'] == 'Dogodek')
                              .toList();
                          final sestanki = events
                              .where((e) => (e as Map<String, dynamic>)['type'] == 'Sestanek')
                              .toList();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dogodki.isNotEmpty) _buildMarker(Colors.red, dogodki.length),
                              if (sestanki.isNotEmpty) _buildMarker(Colors.blue, sestanki.length),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _selectedEventDetails != null
                      ? _buildEventDetailsWindow()
                      : const Center(child: Text('Izberite datum za ogled podrobnosti.')),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _openEventDetails(DateTime selectedDay) {
    final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final events = _events[normalizedDay];

    if (events != null && events.isNotEmpty) {
      setState(() {
        _selectedEventDetails = events[0];
      });
    }
  }

  Widget _buildEventDetailsWindow() {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_selectedEventDetails!['type']}: ${_selectedEventDetails!['naziv']}',
                style: AppStyles.headerTitle,
              ),
              const SizedBox(height: 8.0),
              if (_selectedEventDetails!.containsKey('opis'))
                Text('Opis: ${_selectedEventDetails!['opis']}'),
              if (_selectedEventDetails!.containsKey('kategorija'))
                Text('Kategorija: ${_selectedEventDetails!['kategorija']}'),
              if (_selectedEventDetails!.containsKey('dnevni_red'))
                Text('Dnevni Red: ${_selectedEventDetails!['dnevni_red']}'),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCounter(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          Row(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                icon,
                size: 28.0,
                color: Colors.black, // Icon color
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(Color color, int count) {
    return Container(
      width: 16.0,
      height: 16.0,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10.0)),
      ),
    );
  }}
