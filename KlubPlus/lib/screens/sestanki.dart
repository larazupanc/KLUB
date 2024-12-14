import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SestankiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sestanki', style: TextStyle(color: Color(0xFF004d40))),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      backgroundColor: Color(0xFAFAFAFA),
      body: StreamBuilder<QuerySnapshot>(
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
              onEdit: () => _showEditMeetingForm(context, doc.id, data),
              onDelete: () => _deleteMeeting(context, doc.id),
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: meetings.length,
            itemBuilder: (context, index) => meetings[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeetingForm(context),
        backgroundColor: Color(0xFF004d40),
        child: const Icon(Icons.add, color: Colors.lightGreenAccent),
      ),
    );
  }

  void _showAddMeetingForm(BuildContext context) {
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
        child: _MeetingForm(),
      ),
    );
  }

  void _showEditMeetingForm(BuildContext context, String docId, Map<String, dynamic> currentData) {
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
        child: _MeetingForm(docId: docId, initialData: currentData),
      ),
    );
  }

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

  void _deleteMeeting(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izbriši sestanek'),
          content: const Text('Ali ste prepričani, da želite izbrisati ta sestanek?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Prekliči'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('sestanki').doc(docId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Sestanek izbrisan.')));
              },
              child: const Text('Izbriši'),
            ),
          ],
        );
      },
    );
  }
}

class _MeetingForm extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;

  const _MeetingForm({this.docId, this.initialData});

  @override
  _MeetingFormState createState() => _MeetingFormState();
}

class _MeetingFormState extends State<_MeetingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _agendaController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['naziv'] ?? '';
      _agendaController.text = widget.initialData!['dnevni_red'] ?? '';
      _selectedDate = (widget.initialData!['datum'] as Timestamp).toDate();
    }
  }

  void _saveMeeting() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final data = {
        'naziv': _titleController.text,
        'datum': Timestamp.fromDate(_selectedDate!),
        'dnevni_red': _agendaController.text,
      };

      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('sestanki').add(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sestanek dodan!')));
      } else {
        await FirebaseFirestore.instance.collection('sestanki').doc(widget.docId).update(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sestanek posodobljen!')));
      }

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prosimo, izpolnite vsa polja.')),
      );
    }
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
              validator: (value) => value!.isEmpty ? 'Naziv je obvezen.' : null,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Izberite datum'
                        : DateFormat('dd. MM. yyyy').format(_selectedDate!),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _agendaController,
              decoration: const InputDecoration(labelText: 'Dnevni red'),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Dnevni red je obvezen.' : null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveMeeting,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004d40)),
              child: const Text('Shrani', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String date;
  final String agenda;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MeetingCard({
    required this.title,
    required this.date,
    required this.agenda,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
                  color: Colors.green[900],
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
            Positioned(
              top: 8.0,
              right: 8.0,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Uredi'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Izbriši'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
