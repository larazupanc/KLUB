import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NekiScreen extends StatelessWidget {
  final Map<String, IconData> categoryIcons = {
    'Zabava': Icons.sports_bar,
    'Humanitarnost': Icons.volunteer_activism,
    'Šport': Icons.directions_bike,
    'Izleti': Icons.directions_bus_sharp,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dogodki', style: TextStyle(color: Color(0xFF004d40))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          final events = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final title = data['naziv'] ?? 'Unknown';
            final date = data['datum'] != null
                ? DateFormat('dd. MM. yyyy').format((data['datum'] as Timestamp).toDate())
                : 'Unknown';
            final addedDate = data['dodano'] != null
                ? DateFormat('dd. MM. yyyy').format((data['dodano'] as Timestamp).toDate())
                : 'Unknown';
            final category = data['kategorija'] ?? 'Unknown';
            final description = data['opis'] ?? 'No description';
            final icon = categoryIcons[category] ?? Icons.event;

            return EventCard(
              title: title,
              date: date,
              addedDate: 'Dodano: $addedDate',
              icon: icon,
              onTap: () => _showEventDetails(context, title, date, addedDate, category, description),
              onEdit: () => _showEditEventForm(context, doc.id, data),
              onDelete: () => _deleteEvent(context, doc.id),
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) => events[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventForm(context),
        backgroundColor: Color(0xFF004d40),
        child: const Icon(Icons.add, color: Colors.lightGreenAccent), // Set the icon color
      ),
    );
  }

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

  void _showEditEventForm(BuildContext context, String docId, Map<String, dynamic> currentData) {
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
        child: _EventForm(docId: docId, initialData: currentData),
      ),
    );
  }

  void _showEventDetails(BuildContext context, String title, String date, String addedDate, String category, String description) {
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
              Text('Dodano: $addedDate'),
              const SizedBox(height: 8.0),
              Text('Kategorija: $category'),
              const SizedBox(height: 8.0),
              Text('Opis: $description'),
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

  void _deleteEvent(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izbriši dogodek'),
          content: const Text('Ali ste prepričani, da želite izbrisati ta dogodek?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Prekliči'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('dogodki').doc(docId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Dogodek izbrisan.')));
              },
              child: const Text('Izbriši'),
            ),
          ],
        );
      },
    );
  }
}

class _EventForm extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;

  const _EventForm({this.docId, this.initialData});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCategory;

  final Map<String, IconData> categoryIcons = {
    'Zabava': Icons.sports_bar,
    'Humanitarnost': Icons.volunteer_activism,
    'Šport': Icons.sports,
    'Izleti': Icons.card_travel,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['naziv'] ?? '';
      _descriptionController.text = widget.initialData!['opis'] ?? '';
      _selectedCategory = widget.initialData!['kategorija'];
      _selectedDate = (widget.initialData!['datum'] as Timestamp).toDate();
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedCategory != null) {
      final data = {
        'naziv': _titleController.text,
        'datum': Timestamp.fromDate(_selectedDate!),
        'kategorija': _selectedCategory,
        'opis': _descriptionController.text,
        'dodano': widget.docId == null ? Timestamp.now() : widget.initialData!['dodano'],
      };

      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('dogodki').add(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dogodek dodan!')));
      } else {
        await FirebaseFirestore.instance.collection('dogodki').doc(widget.docId).update(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dogodek posodobljen!')));
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
              validator: (value) => value!.isEmpty ? 'Naslov je obvezen.' : null,
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
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Kategorija'),
              value: _selectedCategory,
              items: categoryIcons.keys
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(categoryIcons[category], color: Colors.lightGreenAccent),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) => value == null ? 'Izberite kategorijo.' : null,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Opis je obvezen.' : null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004d40)),
              child: const Text('Shrani', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String addedDate;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    required this.title,
    required this.date,
    required this.addedDate,
    required this.icon,
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
                  icon,
                  color: Colors.lightGreenAccent,

                  size: 24.0,
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Datum: $date\n$addedDate'),
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
