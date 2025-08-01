import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cinic_app/auth/views/login1.dart';
import 'package:cinic_app/auth/widgets/auth_header.dart';
import 'package:cinic_app/auth/widgets/auth_button.dart';
import 'package:cinic_app/auth/widgets/auth_text_field.dart';
import 'package:cinic_app/auth/widgets/auth_switch_text.dart';
import 'package:cinic_app/auth/widgets/auth_container.dart'; // تأكد من وجوده

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AuthHeader(),
          AuthContainer(
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

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
                  onToggleVisibility: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  hintText: "Confirm your password",
                  controller: confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  isConfirmPasswordField: true,
                  isObscure: !isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
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
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("كلمة المرور غير متطابقة");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // بيانات المستخدم الأساسية
      final userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': widget.role,
      };

      // ✅ لو طبيب، نزود باقي التفاصيل
      if (widget.role.toLowerCase() == 'doctor') {
        userData['specialty'] = specialtyController.text.trim();
        userData['fee'] = '150 جنيه'; // ممكن تخليه dynamic في المستقبل
        userData['time'] = '10:00 - 4:00'; // ممكن تخليه dynamic كمان
        userData['rating'] = "4.9"; // مبدأياً ثابت
      }

      // حفظ في Firestore
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
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
