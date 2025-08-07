import 'dart:convert';
import 'dart:io';
import 'package:cinic_app/auth/widgets/auth_button.dart';
import 'package:cinic_app/auth/widgets/auth_container.dart';
import 'package:cinic_app/auth/widgets/auth_header.dart';
import 'package:cinic_app/auth/widgets/auth_switch_text.dart';
import 'package:cinic_app/auth/widgets/auth_text_field.dart';
import 'package:cinic_app/auth/views/login1.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DoctorExtraInfoScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String role;

  const DoctorExtraInfoScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  State<DoctorExtraInfoScreen> createState() => _DoctorExtraInfoScreenState();
}

class _DoctorExtraInfoScreenState extends State<DoctorExtraInfoScreen> {
  final TextEditingController descriptionController = TextEditingController();
  String? selectedSpecialty;
  File? _profileImage;
  bool isLoading = false;

  final List<String> specialties = [
    'الأنف والأذن والحنجرة',
    'الباطنة',
    'الجراحة العامة',
    'الجلدية',
    'النساء والتوليد',
    'العيون',
    'العظام',
    'القلب',
    'المخ والأعصاب',
    'المسالك البولية',
    'الأسنان',
    'الأطفال',
    'الطب النفسي',
    'التغذية',
    'التحاليل الطبية',
    'الأورام',
    'التخدير',
    'الروماتيزم',
    'الأمراض المعدية',
    'الطب الطبيعي والتأهيل',
  ];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() => _profileImage = File(pickedImage.path));
    }
  }

  Future<String?> uploadImageToImgbb(File imageFile) async {
    final apiKey = '13bc3617dca04f77981a9c02ea8cbebb';
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());
      final response = await http.post(url, body: {"image": base64Image});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _completeSignUp() async {
    if (selectedSpecialty == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String imageUrl = 'https://i.ibb.co/YTN2gGk/default-avatar.png';
      if (_profileImage != null) {
        final uploadedUrl = await uploadImageToImgbb(_profileImage!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': widget.name,
            'email': widget.email,
            'role': widget.role,
            'imageUrl': imageUrl,
            'specialty': selectedSpecialty,
            'description': descriptionController.text.trim(),
            'fee': '150 EGP',
            'time': '10:00 - 4:00',
            'rating': '4.9',
          });

      Navigator.pushReplacementNamed(context, '/doctorDashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during sign up")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AuthHeader(),
          AuthContainer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Doctor's Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xff285DD8).withOpacity(0.2),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Color(0xff285DD8),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Choose Specialty',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    value: selectedSpecialty,
                    onChanged: (value) =>
                        setState(() => selectedSpecialty = value),
                    items: specialties
                        .map(
                          (specialty) => DropdownMenuItem(
                            value: specialty,
                            child: Text(specialty),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter a brief description",
                    controller: descriptionController,
                    prefixIcon: Icons.description,
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Sign Up",
                    isLoading: isLoading,
                    onPressed: _completeSignUp,
                  ),
                  const SizedBox(height: 15),
                  AuthSwitchText(
                    text: "Already have an account? ",
                    linkText: "Sign in",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
