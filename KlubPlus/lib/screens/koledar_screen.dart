import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testni_app/css/styles.dart';
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

  @override
  void initState() {
    super.initState();
    _loadEvents();
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
      appBar: AppBar(
        title: const Text(
          "Koledar",
          style: AppStyles.headerTitle,
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppStyles.iconColor),
      ),
      backgroundColor: Color(0xFAFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  _focusedDay = focusedDay;
                  _selectedEventDetails = null;
                });
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:  Colors.white,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppStyles.selectedDayColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent,
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
                      if (dogodki.isNotEmpty)
                        _buildMarker(Colors.red, dogodki.length),
                      if (sestanki.isNotEmpty)
                        _buildMarker(Colors.blue, sestanki.length),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Selected Date: ${_selectedDay.toLocal()}".split(' ')[0],
              style: AppStyles.selectedDateTextStyle,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] != null
                  ? ListView.builder(
                itemCount: _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]!.length,
                itemBuilder: (context, index) {
                  final event = _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]![index];
                  return Card(
                    child: ListTile(
                      title: Text('${event['type']}: ${event['naziv']}'),
                      onTap: () {
                        setState(() {
                          _selectedEventDetails = event;
                        });
                      },
                    ),
                  );
                },
              )
                  : const Center(child: Text('Na ta dan ni dogodkov.')),
            ),
            const SizedBox(height: 16.0),
            if (_selectedEventDetails != null) _buildEventDetailsWindow(),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(Color color, int count) {
    return Container(
      width: 16.0,
      height: 16.0,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
}
