import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testni_app/css/styles.dart';
import 'package:intl/intl.dart';

import 'home_screen.dart'; // Import where EventCard is defined

class NekiScreen extends StatelessWidget {
  const NekiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Dogodki', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dogodki').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No dogodek found.'));
          }

          String formatDate(dynamic value) {
            if (value is Timestamp) {
              return DateFormat('dd. MM. yyyy').format(value.toDate());
            } else if (value is String) {
              return value;
            } else {
              return 'Unknown date';
            }
          }

          final events = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final title = data['naziv'] ?? 'Unknown';
            final date = formatDate(data['datum']);
            final addedDate = formatDate(data['dodano']);

            return EventCard(
              title: title,
              date: date,
              addedDate: addedDate,
              icon: Icons.event,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: events,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventForm(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to show a form to add a new event
  void _showAddEventForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: _EventForm(),
      ),
    );
  }
}

// Stateful widget for the event form
class _EventForm extends StatefulWidget {
  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Function to save the event to Firestore
  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('dogodki').add({
        'naziv': _titleController.text,
        'datum': Timestamp.fromDate(DateFormat('dd. MM. yyyy').parse(_dateController.text)),
        'kategorija': _categoryController.text,
        'opis': _descriptionController.text,
        'dodano': Timestamp.now(),
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dogodek added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Naziv'),
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Datum (dd. MM. yyyy)',
                hintText: 'e.g., 15. 7. 2024',
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a date' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategorija'),
              validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Dogodek', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
