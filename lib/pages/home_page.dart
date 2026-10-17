import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/bottom_nav_bar.dart';
import 'cards_page.dart';
import 'store_page.dart';
import 'solutions_page.dart';
import 'account_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String? routerIp;
  const HomePage({super.key, this.routerIp});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 4; // الصفحة الرئيسية افتراضياً

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AccountPage(),
      const SolutionsPage(),
      const StorePage(),
      const CardsPage(),
      HomeContent(routerIp: widget.routerIp),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F2B48),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CommonHeader(
          connectionName: 'MikroTik — ${widget.routerIp ?? '192.168.88.1'}',
          isOnline: true,
        ),
      ),
      body: pages[_currentIndex],
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
class HomeContent extends StatefulWidget {
  final String? routerIp;
  const HomeContent({super.key, this.routerIp});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = SupabaseDataService.fetchDashboardStats();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

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
          FutureBuilder<Map<String, int>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final loading = snapshot.connectionState == ConnectionState.waiting;
              final stats = snapshot.data;
              final clients = loading ? '...' : '${stats?['activeClients'] ?? 0}';
              final packages = loading ? '...' : '${stats?['activePackages'] ?? 0}';
              final printed = loading ? '...' : '${stats?['printedToday'] ?? 0}';

              return Column(
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: _buildStatCard('العملاء النشطون', clients, Icons.people, const Color(0xFF1E88E5)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('الباقات المفعلة', packages, Icons.wifi, Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: _buildStatCard('الطباعات اليوم', printed, Icons.print, Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('حالة النظام', 'ممتاز', Icons.check_circle, Colors.teal),
                      ),
                    ],
                  ),
                ],
              );
            },
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
              onPressed: _logout,
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
                style: const TextStyle(
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
