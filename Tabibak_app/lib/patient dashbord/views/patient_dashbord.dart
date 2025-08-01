import 'package:cinic_app/auth/views/login1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/doctor_cart.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                Text(
                  "Hello",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
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
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Doctor')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return DoctorCard(
                name: doc['name'],
                specialty: doc['specialty'],
                imageUrl: doc.data().toString().contains('imageUrl')
                    ? doc['imageUrl']
                    : 'https://cdn-icons-png.flaticon.com/512/147/147142.png',

                onRequest: () => sendRequestToDoctor(doc.id),
              );
            },
          );
        },
      ),
    );
  }

  void sendRequestToDoctor(String doctorId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('requests').add({
      'doctorId': doctorId,
      'patientId': currentUser.uid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
