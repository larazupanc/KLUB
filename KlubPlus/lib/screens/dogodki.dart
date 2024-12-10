import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('dogodki').doc('dogodek').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No dogodek found.'));
          }

          // Fetch document data
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final naziv = data['naziv'] ?? 'Unknown';
          final datum = data['datum'] ?? 'Unknown date';
          final opis = data['opis'] ?? 'No description';
          final kategorija = data['kategorija'] ?? 'No category';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Datum: $datum\nOpis: $opis\nKategorija: $kategorija',
                  style: const TextStyle(color: Colors.black54),
                ),
                leading: const Icon(Icons.event, color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}
