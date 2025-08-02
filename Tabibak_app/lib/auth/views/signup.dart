import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:cinic_app/auth/views/login1.dart';
import 'package:cinic_app/auth/widgets/auth_header.dart';
import 'package:cinic_app/auth/widgets/auth_button.dart';
import 'package:cinic_app/auth/widgets/auth_text_field.dart';
import 'package:cinic_app/auth/widgets/auth_switch_text.dart';
import 'package:cinic_app/auth/widgets/auth_container.dart';

class SignUp extends StatefulWidget {
  final String role;

  const SignUp({super.key, required this.role});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
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
        print("خطأ أثناء رفع الصورة: ${response.body}");
        return null;
      }
    } catch (e) {
      print("استثناء أثناء رفع الصورة: $e");
      return null;
    }
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("كلمة المرور غير متطابقة");
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (_profileImage != null) {
        imageUrl = await uploadImageToImgbb(_profileImage!);
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      Map<String, dynamic> userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': widget.role,
        'imageUrl': imageUrl ?? '',
      };

      if (widget.role.toLowerCase() == 'doctor') {
        userData.addAll({
          'specialty': specialtyController.text.trim(),
          'fee': '150 جنيه',
          'time': '10:00 - 4:00',
          'rating': '4.9',
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      _showSnackBar("تم إنشاء الحساب بنجاح 🎉");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "حدث خطأ أثناء التسجيل");
    } catch (e) {
      _showSnackBar("حدث خطأ غير متوقع");
      print(e);
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    "Register with us!",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your information is safe with us",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xff285DD8).withOpacity(0.2),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Color(0xff285DD8),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),
                  AuthTextField(
                    hintText: "Enter your full name",
                    controller: nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your email",
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                  ),

                  if (widget.role.toLowerCase() == 'doctor') ...[
                    const SizedBox(height: 15),
                    AuthTextField(
                      hintText: "Enter your specialty",
                      controller: specialtyController,
                      prefixIcon: Icons.local_hospital,
                    ),
                  ],

                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your password",
                    controller: passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPasswordField: true,
                    isObscure: !isPasswordVisible,
                    onToggleVisibility: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Confirm your password",
                    controller: confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isConfirmPasswordField: true,
                    isObscure: !isConfirmPasswordVisible,
                    onToggleVisibility: () => setState(
                      () =>
                          isConfirmPasswordVisible = !isConfirmPasswordVisible,
                    ),
                  ),

                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Sign Up",
                    isLoading: isLoading,
                    onPressed: _signUp,
                  ),
                  const SizedBox(height: 20),
                  AuthSwitchText(
                    text: "Already have an account? ",
                    linkText: "Sign in",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
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
