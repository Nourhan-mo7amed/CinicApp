import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _specialtyController; // عرض فقط
  late TextEditingController _emailController; // عرض فقط
  late TextEditingController _experienceController;
  late TextEditingController _feeController;
  late TextEditingController _patientsController; // عرض فقط
  late TextEditingController _timeController;
  late TextEditingController _availabilityController; // عرض فقط
  late TextEditingController _descriptionController;

  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;

  // بيانات الدكتور الحالية
  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();

    // انشئ الكنترولرز بقيم فاضية مؤقتًا
    _nameController = TextEditingController();
    _specialtyController = TextEditingController();
    _emailController = TextEditingController();
    _experienceController = TextEditingController();
    _feeController = TextEditingController();
    _patientsController = TextEditingController();
    _timeController = TextEditingController();
    _availabilityController = TextEditingController();
    _descriptionController = TextEditingController();

    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _patientsController.dispose();
    _timeController.dispose();
    _availabilityController.dispose();
    _descriptionController.dispose();

    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _specialtyController.text = data['specialty'] ?? '';
    _emailController.text = data['email'] ?? '';
    _experienceController.text = (data['experience']?.toString()) ?? '';
    _feeController.text = (data['fee']?.toString()) ?? '';
    _patientsController.text = (data['patients']?.toString()) ?? '';
    _timeController.text = data['time'] ?? '';
    _availabilityController.text = data['availability'] ?? '';
    _descriptionController.text = data['description'] ?? '';

    _phoneController.text = data['phone'] ?? '';
    _addressController.text = data['address'] ?? '';
  }

  Future<void> _saveChanges() async {
    if (doctorData == null) return;

    final docId = doctorData!['id'];
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor ID not found, cannot update')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'name': _nameController.text.trim(),
        'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
        'fee': double.tryParse(_feeController.text.trim()) ?? 0,
        'time': _timeController.text.trim(),
        'description': _descriptionController.text.trim(),

        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save changes: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (_isEditing && enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xff285DD8)),
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else {
      return _buildInfoTile(icon, label, controller.text);
    }
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
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
              '$title: ${value.isEmpty ? "Not Available" : value}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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
          color: Color(0xff285DD8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // دي علشان تخلي لون السهم أبيض

        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                // لو ضغط إغلاق أثناء التعديل، رجع البيانات الأصلية
                if (doctorData != null) {
                  _populateControllers(doctorData!);
                }
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No data available'));
          }

          doctorData = snapshot.data!.data() as Map<String, dynamic>;
          doctorData!['id'] = snapshot.data!.id;

          // عبي الكنترولرز من البيانات (لكن فقط لو مش في وضع تعديل حتى ما تخسرش التعديلات اللي المستخدم بدأ فيها)
          if (!_isEditing) {
            _populateControllers(doctorData!);
          }

          final imageUrl = doctorData!['imageUrl'] ?? '';

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
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
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                              ),
                              const SizedBox(height: 12),
                              _isEditing
                                  ? TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    )
                                  : Text(
                                      'Dr. ${_nameController.text}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff285DD8),
                                      ),
                                    ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _specialtyController.text.isEmpty
                                        ? 'Specialty Not Available'
                                        : _specialtyController.text,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctorData!['rating'] ?? '0'} / 5',
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
                      _buildInfoTile(
                        Icons.email,
                        'Email',
                        _emailController.text,
                      ),
                      _buildEditableField(
                        icon: Icons.phone,
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildEditableField(
                        icon: Icons.home,
                        label: 'Address',
                        controller: _addressController,
                      ),
                      _buildSectionTitle("Experience & Specialty"),
                      _buildEditableField(
                        icon: Icons.school,
                        label: 'Experience (years)',
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildEditableField(
                        icon: Icons.money,
                        label: 'Fee',
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInfoTile(
                        Icons.people,
                        'Patients',
                        _patientsController.text,
                      ),
                      _buildEditableField(
                        icon: Icons.schedule,
                        label: 'Working Hours',
                        controller: _timeController,
                      ),
                      _buildInfoTile(
                        Icons.event_available,
                        'Availability',
                        _availabilityController.text,
                      ),

                      _buildSectionTitle("Additional Information"),
                      _buildEditableField(
                        icon: Icons.description,
                        label: 'Description',
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                      ),
                      _buildInfoTile(
                        Icons.reviews,
                        'Reviews Count',
                        '${doctorData!['reviews'] ?? '29'}',
                      ),

                      const SizedBox(height: 30),

                      if (_isEditing)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff285DD8),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveChanges,
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
