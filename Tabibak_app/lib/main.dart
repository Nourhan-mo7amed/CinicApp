import 'package:cinic_app/auth/views/login1.dart';
import 'package:cinic_app/intro/splash.dart';
import 'package:cinic_app/patient%20dashbord/views/patient_dashbord.dart';
import 'package:cinic_app/doctor%20dashbord/views/doctor_dashbord.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // يبدأ من الاسبلاش
      routes: {
        '/login': (context) => const LoginScreen(),
        '/doctorDashboard': (context) => DoctorDashboard(),
        '/patientDashboard': (context) => PatientDashboard(),
      },
    );
  }
}
