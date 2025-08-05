import 'package:cinic_app/auth/views/login1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAcceptedRequestsScreen(),
          _buildPendingRequestsScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'البروفايل'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Row(
              children: const [
                CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                SizedBox(width: 12),
                Text("جار التحميل...", style: TextStyle(color: Colors.grey)),
              ],
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = data['name'] ?? 'Doctor';
          final firstName = fullName.toString().split(' ').first;
          final imageUrl = data['imageUrl'] ?? '';

          return Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    "$firstName!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
          );
        },
      ),
    );
  }

  Widget _buildAcceptedRequestsScreen() {
    return _buildRequestList(
      status: 'accepted',
      emptyMessage: "لا يوجد حجوزات مقبولة",
      titleBuilder: (patientName) => "حجز مؤكد لـ $patientName",
      subtitle: "تم تأكيد الحجز بنجاح",
      actionsBuilder: null,
    );
  }

  Widget _buildPendingRequestsScreen() {
    return _buildRequestList(
      status: 'pending',
      emptyMessage: "لا يوجد طلبات حالياً",
      titleBuilder: (patientName) => "طلب من $patientName",
      subtitle: "يريد حجز كشف معك",
      actionsBuilder: (request, patientId) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              await request.reference.update({'status': 'accepted'});
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(patientId)
                  .update({'isBooked': true, 'bookedDoctorId': doctorId});
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await request.reference.update({'status': 'rejected'});
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(patientId)
                  .update({
                    'isBooked': false,
                    'bookedDoctorId': FieldValue.delete(),
                  });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList({
    required String status,
    required String emptyMessage,
    required String Function(String) titleBuilder,
    required String subtitle,
    required Widget? Function(QueryDocumentSnapshot, String)? actionsBuilder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final patientId = request['patientId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(patientId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const ListTile(title: Text("تحميل بيانات المريض..."));
                }

                final patientData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final patientName = patientData['name'] ?? 'مريض غير معروف';

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(titleBuilder(patientName)),
                    subtitle: Text(subtitle),
                    trailing: actionsBuilder != null
                        ? actionsBuilder(request, patientId)
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return Center(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const CircularProgressIndicator();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'اسم غير معروف';
          final email = data['email'] ?? 'بريد غير معروف';
          final imageUrl = data['imageUrl'] ?? '';

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(email, style: const TextStyle(color: Colors.grey)),
            ],
          );
        },
      ),
    );
  }
}
