import 'package:cinic_app/auth/views/login1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DoctorProfileScreen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = data['name'] ?? 'Doctor';
          final firstName = fullName.toString().split(' ').first;
          final imageUrl = data['imageUrl'] ?? '';

          return Column(
            children: [
              Stack(
                children: [
                  // الخلفية العلوية
                  Container(
                    height: 270,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/imeges/bg1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // صورة الدكتور والاسم
                  Positioned(
                    top: 50,
                    left: 15,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const AssetImage(
                                      'assets/images/default_avatar.png',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Dr.$firstName!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorProfileScreen(),
                            ),
                          );
                        } else if (value == 'logout') {
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("profile"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("logout"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // الأيقونات في المنتصف
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _selectedIndex = 0),
                        icon: const Icon(Icons.today),
                        label: const Text("Today Appointments"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _selectedIndex == 0
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          foregroundColor: _selectedIndex == 0
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        icon: const Icon(Icons.pending_actions),
                        label: const Text("Requests"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _selectedIndex == 1
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          foregroundColor: _selectedIndex == 1
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildAcceptedRequestsScreen(),
                    _buildPendingRequestsScreen(),
                    _buildProfileScreen(),
                  ],
                ),
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
      emptyMessage: "No accepted bookings",
      titleBuilder: (patientName) => "Confirmed booking for $patientName",
      subtitle: "Booking confirmed successfully",
      actionsBuilder: null,
    );
  }

  Widget _buildPendingRequestsScreen() {
    return _buildRequestList(
      status: 'pending',
      emptyMessage: "No requests currently",
      titleBuilder: (patientName) => "Request from $patientName",
      subtitle: "wants to book an appointment with you",
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const SizedBox();
                }

                final patientData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final patientName = patientData['name'] ?? 'مريض غير معروف';
                final patientImage = patientData['imageUrl'] ?? '';
                final dateField =
                    (request.data() as Map<String, dynamic>)['date'];
                String bookingDate = 'غير محدد';

                if (dateField != null && dateField is Timestamp) {
                  final localDate = dateField
                      .toDate()
                      .toLocal(); // تحويل للتوقيت المحلي
                  bookingDate = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(localDate);
                }

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: patientImage.isNotEmpty
                          ? NetworkImage(patientImage)
                          : const AssetImage('assets/images/default_avatar.png')
                                as ImageProvider,
                    ),
                    title: Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "موعد: $bookingDate",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: actionsBuilder != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  await request.reference.update({
                                    'status': 'accepted',
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(patientId)
                                      .update({
                                        'isBooked': true,
                                        'bookedDoctorId': doctorId,
                                      });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  await request.reference.update({
                                    'status': 'rejected',
                                  });
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
                          )
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
