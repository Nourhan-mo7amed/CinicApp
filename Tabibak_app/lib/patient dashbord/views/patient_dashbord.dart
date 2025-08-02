/* Updated UI enhancements for PatientDashboard */

import 'package:cinic_app/auth/views/login1.dart';
import 'package:cinic_app/patient%20dashbord/views/doctor_profile_screen.dart';
import 'package:cinic_app/patient%20dashbord/views/p.dart';
import 'package:cinic_app/patient%20dashbord/widgets/doctor_cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> toggleBooking(String doctorId, bool isPending) async {
    try {
      final requestRef = FirebaseFirestore.instance.collection('requests');

      if (isPending) {
        final snapshot = await requestRef
            .where('patientId', isEqualTo: currentUser!.uid)
            .where('doctorId', isEqualTo: doctorId)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        await requestRef.add({
          'doctorId': doctorId,
          'patientId': currentUser!.uid,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء تنفيذ الحجز")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("لم يتم تسجيل الدخول")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildBookingsTab(),
          const Center(child: Text('المفضلة')),
          PatientProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('patientId', isEqualTo: currentUser!.uid)
            .where('status', whereIn: ['pending', 'accepted'])
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
              final doctors = doctorSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final specialty = (data['specialty'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(_searchQuery) ||
                    specialty.contains(_searchQuery);
              }).toList();

              if (doctors.isEmpty) {
                return const Center(child: Text("لا يوجد أطباء حاليًا"));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildServices(),
                    const SizedBox(height: 24),
                    const Text(
                      "Top Doctors",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doc = doctors[index];
                          final doctorId = doc.id;
                          String bookingStatus = '';
                          for (var request in requestSnapshot.data!.docs) {
                            if (request['doctorId'] == doctorId) {
                              bookingStatus = request['status'];
                              break;
                            }
                          }

                          final data = doc.data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DoctorProfileScreen(doctorData: data),
                                ),
                              );
                            },
                            child: DoctorCard(
                              name: data['name'] ?? 'غير معروف',
                              specialty: data['specialty'] ?? 'غير محدد',
                              imageUrl: data.containsKey('imageUrl')
                                  ? data['imageUrl']
                                  : 'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                              bookingStatus: bookingStatus,
                              time: data['time'] ?? 'غير محدد',
                              fee: data['fee']?.toString() ?? 'غير محدد',
                              rating: data['rating']?.toString() ?? '0.0',
                              onRequest: () => toggleBooking(
                                doctorId,
                                bookingStatus == 'pending',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingsTab() {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('patientId', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, bookingSnapshot) {
          if (!bookingSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final acceptedBookings = bookingSnapshot.data!.docs;
          if (acceptedBookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات مقبولة'));
          }

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

              return ListView(
                padding: const EdgeInsets.all(16),
                children: acceptedBookings.map((booking) {
                  final doctorId = booking['doctorId'];
                  final matchingDoctors = doctors
                      .where((doc) => doc.id == doctorId)
                      .toList();
                  if (matchingDoctors.isEmpty) return const SizedBox();
                  final doctor = matchingDoctors.first;

                  final data = doctor.data() as Map<String, dynamic>;

                  return DoctorCard(
                    name: data['name'] ?? 'غير معروف',
                    specialty: data['specialty'] ?? 'غير محدد',
                    imageUrl: data.containsKey('imageUrl')
                        ? data['imageUrl']
                        : 'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                    bookingStatus: 'accepted',
                    time: data.containsKey('time') ? data['time'] : 'غير محدد',
                    fee: data.containsKey('fee')
                        ? data['fee'].toString()
                        : 'غير محدد',
                    rating: data.containsKey('rating')
                        ? data['rating'].toString()
                        : '0.0',
                    onRequest: () {},
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final imageUrl = userData?['imageUrl'] as String?;

            return CircleAvatar(
              radius: 26,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
            );
          },
        ),

        const SizedBox(width: 12),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final fullName = userData?['name'] ?? 'مستخدم';
            final firstName = fullName.toString().split(' ').first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  "$firstName!",

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),

        const Spacer(),
        const Icon(
          Icons.notifications_none_rounded,
          size: 28,
          color: Colors.blueAccent,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
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
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: "... ابحث عن طبيب",
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildServices() {
    final services = [
      {'icon': Icons.medical_services, 'label': 'Odontology'},
      {'icon': Icons.psychology, 'label': 'Neurology'},
      {'icon': Icons.favorite, 'label': 'Cardiology'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: services.map((service) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                service['icon'] as IconData,
                color: Colors.blueAccent,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['label'] as String,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        );
      }).toList(),
    );
  }
}
