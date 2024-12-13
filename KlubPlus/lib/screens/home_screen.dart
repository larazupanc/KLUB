import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Color(0xFF004d40))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      body: Column(
        children: [
          // Section for Meetings
          _buildMeetingList(context),
          // Section for Events
          _buildEventList(context),
        ],
      ),
    );
  }

  // Fetch and display meetings
  Widget _buildMeetingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sestanki')
          .limit(2)  // Limit the number of meetings to 2
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Prišlo je do napake: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Ni sestankov.'));
        }

        final meetings = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final title = data['naziv'] ?? 'Unknown';
          final date = data['datum'] != null
              ? DateFormat('dd. MM. yyyy').format((data['datum'] as Timestamp).toDate())
              : 'Unknown';
          final agenda = data['dnevni_red'] ?? 'Ni dnevnega reda';

          return MeetingCard(
            title: title,
            date: date,
            agenda: agenda,
            onTap: () => _showMeetingDetails(context, title, date, agenda),
          );
        }).toList();

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Sestanki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meetings.length,
              itemBuilder: (context, index) => meetings[index],
            ),
          ],
        );
      },
    );
  }

  // Fetch and display events
  Widget _buildEventList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dogodki')
          .limit(2)  // Limit the number of events to 2
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Prišlo je do napake: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Ni dogodkov.'));
        }

        final events = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final title = data['naziv'] ?? 'Unknown';
          final date = data['datum'] != null
              ? DateFormat('dd. MM. yyyy').format((data['datum'] as Timestamp).toDate())
              : 'Unknown';
          final agenda = data['dnevni_red'] ?? 'Ni dnevnega reda';

          return MeetingCard(
            title: title,
            date: date,
            agenda: agenda,
            onTap: () => _showEventDetails(context, title, date, agenda),
          );
        }).toList();

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Dogodki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) => events[index],
            ),
          ],
        );
      },
    );
  }

  // Show meeting details in a dialog
  void _showMeetingDetails(BuildContext context, String title, String date, String agenda) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datum: $date'),
              const SizedBox(height: 8.0),
              Text('Dnevni red: $agenda'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zapri'),
            ),
          ],
        );
      },
    );
  }

  // Show event details in a dialog
  void _showEventDetails(BuildContext context, String title, String date, String agenda) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datum: $date'),
              const SizedBox(height: 8.0),
              Text('Dnevni red: $agenda'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zapri'),
            ),
          ],
        );
      },
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String date;
  final String agenda;
  final VoidCallback onTap;

  const MeetingCard({
    required this.title,
    required this.date,
    required this.agenda,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Stack(
          children: [
            ListTile(
              leading: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: Color(0xFF004d40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cases_sharp,
                  color: Colors.lightGreenAccent,
                  size: 24.0,
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Datum: $date\nDnevni red: $agenda'),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }
}
