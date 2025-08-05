import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isBooked = false;
  String requestStatus = 'none'; // 'pending', 'accepted', 'none'
  final String patientId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkBookingStatus();
  }

  Future<void> checkBookingStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('doctorId', isEqualTo: widget.doctorData['id'])
        .where('patientId', isEqualTo: patientId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        isBooked = true;
        requestStatus = data['status']; // 'pending' or 'accepted'
      });
    }
  }

  Future<void> handleBooking() async {
    final docRef = FirebaseFirestore.instance.collection('requests').doc();

    await docRef.set({
      'doctorId': widget.doctorData['id'],
      'patientId': patientId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      isBooked = true;
      requestStatus = 'pending';
    });
  }

  Future<void> cancelBooking() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('doctorId', isEqualTo: widget.doctorData['id'])
        .where('patientId', isEqualTo: patientId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      isBooked = false;
      requestStatus = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorData['name'] ?? 'Doctor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                widget.doctorData['imageUrl'] ?? '',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.doctorData['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(widget.doctorData['specialty'] ?? ''),
            const SizedBox(height: 16),
            Text(
              widget.doctorData['description'] ?? 'لا يوجد وصف متاح',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (requestStatus == 'accepted') ...[
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('تم القبول'),
              ),
            ] else if (isBooked) ...[
              ElevatedButton(
                onPressed: cancelBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('إلغاء الحجز'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: handleBooking,
                child: const Text('احجز مع الدكتور'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
