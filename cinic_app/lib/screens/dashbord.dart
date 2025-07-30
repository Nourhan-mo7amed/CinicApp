import 'package:flutter/material.dart';

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({super.key});

  @override
  State<MedicalDashboard> createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard> {
  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    DoctorsScreen(),
    AppointmentsScreen(),
    SettingsScreen(),
  ];

  final List<String> titles = ['Home', 'Doctors', 'Appointments', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          titles[currentIndex],
          style: const TextStyle(
            color: Color(0xff285DD8),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: screens[currentIndex],

      bottomNavigationBar: Stack(
        children: [
          // الشكل الخلفي للموجة أو الإنحناء
          CustomPaint(
            size: const Size(double.infinity, 80),
            painter: NavBarPainter(),
          ),

          SizedBox(
            height: 80,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: currentIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => setState(() => currentIndex = index),
              items: [
                _buildNavItem(icon: Icons.home, index: 0),
                _buildNavItem(icon: Icons.local_hospital, index: 1),
                _buildNavItem(icon: Icons.calendar_today, index: 2),
                _buildNavItem(icon: Icons.settings, index: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: currentIndex == index
            ? BoxDecoration(
                color: const Color(0xff285DD8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff285DD8).withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : const BoxDecoration(),
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 24),
      ),
      label: '',
    );
  }
}

class NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;

    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.3, 0);

    path.quadraticBezierTo(size.width * 0.5, 40, size.width * 0.7, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    canvas.drawShadow(path, Colors.black26, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🏠 Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🏠 Welcome to Medical App",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// 👨‍⚕️ Doctors Screen
class DoctorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "👨‍⚕️ List of Doctors",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// 📅 Appointments Screen
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "📅 Your Appointments",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ⚙️ Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "⚙️ Settings",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}
