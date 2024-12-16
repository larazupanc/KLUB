import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class ObvestilaScreen extends StatefulWidget {
  const ObvestilaScreen({super.key});

  @override
  State<ObvestilaScreen> createState() => _ObvestilaScreenState();
}

class _ObvestilaScreenState extends State<ObvestilaScreen> {
  List<String> alertMessages = [];

  @override
  void initState() {
    super.initState();
    _checkForUpcomingMeetings();
  }

  Future<void> _checkForUpcomingMeetings() async {
    try {
      // Fetch all meetings from the 'sestanki' collection
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('sestanki').get();

      final DateTime now = DateTime.now();
      List<String> newAlertMessages = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp timestamp = data['datum']; // Firestore timestamp
        final DateTime meetingDate = timestamp.toDate().toLocal(); // Convert to local time
        final int daysDifference = meetingDate.difference(now).inDays;

        print('Meeting Date: $meetingDate, Days Difference: $daysDifference');

        // Check if the meeting is within the next 7 days (including today)
        if (daysDifference >= 0 && daysDifference <= 7) {
          newAlertMessages.add(
            "Sestanek je cez $daysDifference ${daysDifference == 1 ? 'dan' : 'dni'}: ${data['naziv']} dne ${DateFormat.yMMMMd('sl_SI').format(meetingDate)}.",
          );
        }
      }

      // Update the alertMessages list with the new messages
      setState(() {
        alertMessages = newAlertMessages;
      });

    } catch (e) {
      print('Error fetching meeting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Obvestila"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: alertMessages.isNotEmpty
            ? ListView.builder(
          itemCount: alertMessages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                alertMessages[index],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          },
        )
            : const Text("Nabiralnik je prazen."),
      ),
    );
  }
}
