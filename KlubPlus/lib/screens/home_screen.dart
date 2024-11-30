import 'package:flutter/material.dart';
import 'package:testni_app/css/styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihajajoči dogodki', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: "Dogodki"),
            const EventCard(
              title: "Novoletni Izlet",
              date: "30. 12. 2024 - 2. 1. 2025",
              addedDate: "Dodano 31 Dec.",
              icon: Icons.directions_bus,
            ),
            const EventCard(
              title: "Dobrodelni kilometri",
              date: "1-30. 6. 2024",
              addedDate: "Dodano 31 Dec.",
              icon: Icons.directions_run,
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: "Sestanki", viewAll: true),
            const MeetingCard(
              title: "17. redna seja",
              date: "21. 12. 2024",
            ),
            const MeetingCard(
              title: "1. redna seja",
              date: "5. 1. 2025",
            ),
          ],
        ),
      ),

    );
  }
}
class SectionTitle extends StatelessWidget {
  final String title;
  final bool viewAll;

  const SectionTitle({required this.title, this.viewAll = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyles.sectionTitle,
        ),
        if (viewAll)
          TextButton(
            onPressed: () {},
            style: AppStyles.greenTextButton,
            child: const Text('Poglej vse'),
          ),
      ],
    );
  }
}class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String addedDate;
  final IconData icon;

  const EventCard({
    required this.title,
    required this.date,
    required this.addedDate,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: AppStyles.cardBoxDecoration,
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: AppStyles.iconBackgroundColor, // Green background
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: AppStyles.iconColor),
        ),
        title: Text(title, style: AppStyles.cardTitle),
        subtitle: Text('$date\n$addedDate', style: AppStyles.cardSubtitle),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String date;

  const MeetingCard({required this.title, required this.date, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: AppStyles.cardBoxDecoration,
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: AppStyles.iconBackgroundColor, // Green background
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8.0),
          child: const Icon(Icons.meeting_room, color: AppStyles.iconColor),
        ),
        title: Text(title, style: AppStyles.cardTitle),
        subtitle: Text(date, style: AppStyles.cardSubtitle),
        trailing: TextButton(
          onPressed: () {},
          style: AppStyles.greenTextButton,
          child: const Text('Poglej dnevni red'),
        ),
      ),
    );
  }
}
