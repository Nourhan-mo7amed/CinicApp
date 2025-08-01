import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String imagePath;
  final String name;
  final String role;
  final double rating;
  final int reviews;

  const DoctorProfileScreen({
    super.key,
    required this.imagePath,
    required this.name,
    required this.role,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(imagePath, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(role, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '$rating ($reviews reviews)',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.favorite_border),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              InfoItem(icon: Icons.person, label: 'Patients', value: '116+'),
              InfoItem(icon: Icons.check_circle, label: 'Years', value: '3+'),
              InfoItem(icon: Icons.star, label: 'Rating', value: '4.9'),
              InfoItem(icon: Icons.reviews, label: 'Reviews', value: '90+'),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "About Me",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Dr. Ali Uzair is the top most cardiologist specialist in Crist Hospital in London, UK. "
            "He achieved several awards for her wonderful contribution Read More...",
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Navigate to booking screen
              },
              child: const Text(
                "Book Appointment",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
