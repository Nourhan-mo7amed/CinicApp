import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff285DD8),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Doctor image and basic info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        doctorData['imageUrl'] ?? '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dr. ${doctorData['name'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff285DD8),
                      ),
                    ),
                    Text(
                      doctorData['specialty'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${doctorData['rating'] ?? '0'} / 5',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Contact Information"),
            _buildInfoTile(Icons.email, 'Email', doctorData['email']),

            _buildSectionTitle("Experience & Specialty"),
            _buildInfoTile(
              Icons.school,
              'Experience',
              '${doctorData['experience'] ?? 2} years',
            ),
            _buildInfoTile(Icons.money, 'Fee', doctorData['fee']),
            _buildInfoTile(Icons.people, 'Patients', doctorData['patients']),
            _buildInfoTile(Icons.schedule, 'Working Hours', doctorData['time']),
            _buildInfoTile(
              Icons.event_available,
              'Availability',
              doctorData['availability'],
            ),

            _buildSectionTitle("Additional Information"),
            _buildInfoTile(
              Icons.description,
              'Description',
              doctorData['description'],
            ),
            _buildInfoTile(
              Icons.reviews,
              'Reviews Count',
              '${doctorData['reviews'] ?? '0'}',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xff285DD8),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff285DD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff285DD8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: ${value ?? "Not Available"}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
