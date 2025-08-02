import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctorData['name'] ?? 'Doctor Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  doctorData['imageUrl'] ??
                      'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              doctorData['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              doctorData['specialty'] ?? 'Specialty not available',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'About the Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              doctorData['description'] ??
                  'No description provided for this doctor.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._buildReviews(doctorData['reviews']),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReviews(List<dynamic>? reviews) {
    if (reviews == null || reviews.isEmpty) {
      return [const Text('No reviews available.')];
    }

    return reviews.map((review) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.person),
          title: Text(review['name'] ?? 'Anonymous'),
          subtitle: Text(review['comment'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                index < (review['rating'] ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
