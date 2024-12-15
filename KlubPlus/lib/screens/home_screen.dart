import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:testni_app/main.dart';
import 'package:testni_app/screens/obvestilascreen.dart';

class HomeScreen extends StatelessWidget {
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

    body: Column(
        children: [
          // Upper Half: Sestanki
          Expanded(
            child: _buildBlurredSection(
              context,
              title: 'Sestanki',
              contentWidget: _buildMeetingList(context),
            ),
          ),
          // Lower Half: Dogodki
          Expanded(
            child: _buildBlurredSection(
              context,
              title: 'Dogodki',
              contentWidget: _buildEventList(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredSection(BuildContext context, {required String title, required Widget contentWidget}) {
    return Stack(
      children: [
        // Main content
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            contentWidget,
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 20,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Fetch and display meetings
  Widget _buildMeetingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sestanki').snapshots(),
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

        return Column(
          children: snapshot.data!.docs.map((doc) {
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
          }).toList(),
        );
      },
    );
  }

  // Fetch and display events
  Widget _buildEventList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dogodki').snapshots(),
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

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['naziv'] ?? 'Unknown';
            final date = data['datum'] != null
                ? DateFormat('dd. MM. yyyy').format((data['datum'] as Timestamp).toDate())
                : 'Unknown';
            final description = data['opis'] ?? 'Ni opisa';

            return EventCard(
              title: title,
              date: date,
              description: description,
              onTap: () => _showEventDetails(context, title, date, description),
            );
          }).toList(),
        );
      },
    );
  }

  // Dialog for meetings
  void _showMeetingDetails(BuildContext context, String title, String date, String agenda) {
    showDialog(
      context: context,
      builder: (context) {
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Zapri')),
          ],
        );
      },
    );
  }

  // Dialog for events
  void _showEventDetails(BuildContext context, String title, String date, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datum: $date'),
              const SizedBox(height: 8.0),
              Text('Opis: $description'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Zapri')),
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

  const MeetingCard({required this.title, required this.date, required this.agenda, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF004d40),
            child: const Icon(Icons.cases_sharp, color: Colors.lightGreenAccent),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Datum: $date\nDnevni red: $agenda'),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final VoidCallback onTap;

  const EventCard({required this.title, required this.date, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: const Icon(Icons.event, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Datum: $date\nOpis: $description'),
        ),
      ),
    );
  }
}
