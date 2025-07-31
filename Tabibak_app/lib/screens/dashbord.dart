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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBox(),
              const SizedBox(height: 20),
              _buildSectionHeader('Categories'),
              const SizedBox(height: 12),
              _buildCategoriesList(),
              const SizedBox(height: 20),
              _buildSectionHeader('Appointment'),
              const SizedBox(height: 12),
              _buildAppointmentCard(),
              const SizedBox(height: 20),
              const Text(
                'Top Doctors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTopDoctorsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/imeges/doctor1.png'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hi, Fabulf',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '🟢 Online',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const Icon(
          Icons.notifications_none,
          size: 28,
          color: Color(0xff285DD8),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search doctor, category...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text('See all', style: TextStyle(color: Color(0xff285DD8))),
      ],
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryItem(icon: Icons.favorite_border, label: 'Heart'),
          CategoryItem(icon: Icons.local_florist, label: 'Ortho'),
          CategoryItem(icon: Icons.medical_services, label: 'Dental'),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff285DD8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/imeges/doctor1.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dr. Alex Maguire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Cardiologist', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '12 March 2025',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.access_time, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '10:00 AM',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDoctorsList() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          TopDoctorCard(image: 'assets/imeges/doctor1.png', name: 'Dr. Sarah'),
          TopDoctorCard(image: 'assets/imeges/doctor1.png', name: 'Dr. John'),
          TopDoctorCard(image: 'assets/imeges/doctor1.png', name: 'Dr. Lina'),
        ],
      ),
    );
  }
}

// ⬅️ عنصر فئة
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xff285DD8), size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ⬅️ كارت طبيب
class TopDoctorCard extends StatelessWidget {
  final String image;
  final String name;

  const TopDoctorCard({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
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
