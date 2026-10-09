import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../widgets/bottom_nav_bar.dart';
import 'cards_page.dart';
import 'store_page.dart';
import 'solutions_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 4; // الصفحة الرئيسية افتراضياً

  // قائمة الصفحات
  final List<Widget> _pages = const [
    AccountPage(),
    SolutionsPage(),
    StorePage(),
    CardsPage(),
    HomeContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2B48),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const CommonHeader(
          connectionName: 'MikroTik — 192.168.88.1',
          isOnline: true,
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// محتوى الصفحة الرئيسية
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'مرحباً بك، مدير النظام 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'نظرة عامة على نظامك',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // بطاقات الإحصائيات
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _buildStatCard('العملاء النشطون', '128', Icons.people, const Color(0xFF1E88E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('الباقات المفعلة', '45', Icons.wifi, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _buildStatCard('الطباعات اليوم', '32', Icons.print, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('حالة النظام', 'ممتاز', Icons.check_circle, Colors.teal),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // روابط سريعة
          const Text(
            'الوصول السريع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildQuickAccessCard(
            context,
            title: 'إدارة الكروت والباقات',
            subtitle: 'إنشاء وتعديل وطباعة كروت الشبكة',
            icon: Icons.grid_view,
            onTap: () {
              final parent = context.findAncestorStateOfType<_HomePageState>();
              parent?.setState(() => parent._currentIndex = 3);
            },
          ),

          _buildQuickAccessCard(
            context,
            title: 'المتجر والخدمات',
            subtitle: 'باقات Starlink ومستلزمات الشبكات',
            icon: Icons.storefront,
            onTap: () {
              final parent = context.findAncestorStateOfType<_HomePageState>();
              parent?.setState(() => parent._currentIndex = 2);
            },
          ),

          _buildQuickAccessCard(
            context,
            title: 'حلول ومساعدة',
            subtitle: 'دروس وأدلة استخدام النظام',
            icon: Icons.book,
            onTap: () {
              final parent = context.findAncestorStateOfType<_HomePageState>();
              parent?.setState(() => parent._currentIndex = 1);
            },
          ),

          const SizedBox(height: 40),

          // زر تسجيل الخروج
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.15),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1E88E5), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
