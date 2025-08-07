import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isBooked = false;
  String requestStatus = 'none';
  bool isFavorited = false;
  bool isBookingLoading = false;
  final String patientId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkBookingStatus();
    checkFavoriteStatus();
  }

  Future<void> checkBookingStatus() async {
    try {
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
          requestStatus = data['status'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> checkFavoriteStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          isFavorited = true;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleFavorite() async {
    try {
      final favoritesRef = FirebaseFirestore.instance.collection('favorites');
      final snapshot = await favoritesRef
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await favoritesRef.add({
          'doctorId': widget.doctorData['id'],
          'patientId': patientId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          isFavorited = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإضافة إلى المفضلة ❤️'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        setState(() {
          isFavorited = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإزالة من المفضلة'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> handleBooking() async {
    setState(() {
      isBookingLoading = true;
    });
    try {
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
        isBookingLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الحجز بنجاح!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        isBookingLoading = false;
      });
      // Handle error
    }
  }

  Future<void> cancelBooking() async {
    setState(() {
      isBookingLoading = true;
    });
    try {
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
        isBookingLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الحجز بنجاح!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        isBookingLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctorData;
    final String doctorName = "Dr. ${doctor['name'] ?? 'Ali Uzair'}";

    final String specialty = doctor['specialty'] ?? 'Cardiologist and Surgeon';
    final String imageUrl =
        doctor['imageUrl'] ?? 'https://via.placeholder.com/150';
    final String patientsCount = doctor['patients'] ?? '116+';
    final String experienceYears = doctor['experience'] ?? '3+';
    final String rating = doctor['rating'] ?? '4.9';
    final String reviewsCount = doctor['reviews'] ?? '96';
    final String aboutMe =
        doctor['description'] ??
        'Dr. Ali Uzair is the top most cardiologist specialist in Crist Hospital in London, UK. He achieved several awards for her wonderful contribution Read More...';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Doctor', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section with Doctor Image and Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // فقط الصورة داخل Card
                  Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: Image.network(
                              imageUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: toggleFavorite,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorited
                                    ? Colors.redAccent
                                    : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // الاسم، التخصص، والتقييم خارج Card
                  Row(
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$rating (${reviewsCount} reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.person, patientsCount, "Patients"),
                  _buildStatItem(
                    Icons.check_box_outlined,
                    experienceYears,
                    "Years",
                  ),
                  _buildStatItem(Icons.star, rating, "Rating"),
                  _buildStatItem(
                    Icons.chat_bubble_outline,
                    '${reviewsCount}+',
                    "Reviews",
                  ),
                ],
              ),
            ),

            // About Me Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aboutMe,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isBookingLoading || requestStatus == 'accepted'
                ? null
                : isBooked
                ? cancelBooking
                : handleBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: requestStatus == 'accepted'
                  ? Colors.green
                  : isBooked
                  ? Colors.red
                  : const Color(0xFF2B4D78),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isBookingLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 24.0)
                : Text(
                    requestStatus == 'accepted'
                        ? 'Accepted'
                        : isBooked
                        ? 'Cancel Booking'
                        : 'Book Appointment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: const Color(0xFF2B4D78)), // Color from image
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
