import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final VoidCallback onRequest;
  final String bookingStatus;
  final String time; // ← إضافي للتوقيت
  final String fee; // ← إضافي للسعر
  final String rating; // ← إضافي للتقييم

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.onRequest,
    required this.bookingStatus,
    required this.time,
    required this.fee,
    required this.rating,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(specialty,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    const Text("Fee: ",
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(fee, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 2),
                  Text(rating,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed:
                    bookingStatus == 'accepted' ? null : onRequest, // disable if accepted
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(buttonText,
                    style: const TextStyle(fontSize: 13, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
