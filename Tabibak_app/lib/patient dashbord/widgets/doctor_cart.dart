import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final VoidCallback onRequest;
  final String bookingStatus; // ← بدل bool

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.onRequest,
    required this.bookingStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    String buttonText;

    if (bookingStatus == 'accepted') {
      buttonColor = Colors.green;
      buttonText = "تم الحجز";
    } else if (bookingStatus == 'pending') {
      buttonColor = Colors.red;
      buttonText = "إلغاء الحجز";
    } else {
      buttonColor = Colors.blue;
      buttonText = "احجز";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(specialty, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: bookingStatus == 'accepted'
                  ? () {}
                  : onRequest, // ممنوع الحذف لو تم الحجز
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white, // ← لون النص داخل الزر
              ),

              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
