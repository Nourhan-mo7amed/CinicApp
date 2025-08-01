import 'package:cinic_app/auth/views/login1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/doctor_cart.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> toggleBooking(String doctorId, bool alreadyBooked) async {
    final requestRef = FirebaseFirestore.instance.collection('requests');

    if (alreadyBooked) {
      // احذف الحجز من requests
      final snapshot = await requestRef
          .where('patientId', isEqualTo: currentUser!.uid)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      // أضف حجز جديد
      await requestRef.add({
        'doctorId': doctorId,
        'patientId': currentUser!.uid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('patientId', isEqualTo: currentUser!.uid)
            .where(
              'status',
              whereIn: ['pending', 'accepted'],
            ) // ✅ فلتر الحجوزات المقبولة فقط
            .snapshots(),
        builder: (context, requestSnapshot) {
          if (!requestSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookedDoctorIds = requestSnapshot.data!.docs
              .map((doc) => doc['doctorId'] as String)
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Doctor')
                .snapshots(),
            builder: (context, doctorSnapshot) {
              if (!doctorSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final doctors = doctorSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  final doctorId = doc.id;
                  final alreadyBooked = bookedDoctorIds.contains(doctorId);

                  return DoctorCard(
                    name: doc['name'],
                    specialty: doc['specialty'],
                    imageUrl: doc.data().toString().contains('imageUrl')
                        ? doc['imageUrl']
                        : 'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                    isBooked: alreadyBooked,
                    onRequest: () => toggleBooking(doctorId, alreadyBooked),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/imeges/doctor1.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Hello", style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text(
                "Hamza !",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, size: 28),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
