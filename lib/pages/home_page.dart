import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/operator_profile_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/sparkline.dart';
import 'cards_page.dart';
import 'cards_list_page.dart';
import 'monitoring_page.dart';
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
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<OperatorProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = SupabaseDataService.fetchDashboardStats();
    _profileFuture = SupabaseDataService.fetchMyProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _statsFuture = SupabaseDataService.fetchDashboardStats();
      _profileFuture = SupabaseDataService.fetchMyProfile();
    });
    await Future.wait([_statsFuture, _profileFuture]);
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // الترحيب + رصيد الكروت
            FutureBuilder<OperatorProfile?>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final name = snapshot.data?.fullName;
                final greeting = (name == null || name.isEmpty) ? 'مرحباً بك 👋' : 'مرحباً، $name 👋';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'نظرة عامة على نظامك',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // رصيدك من الكروت
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final loading = snapshot.connectionState == ConnectionState.waiting;
                final unused = loading ? null : (snapshot.data?['unusedCards'] as int? ?? 0);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF0F2B48)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.credit_card, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('رصيدك من الكروت', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              loading ? '...' : '$unused كرت متاح',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // بطاقة جهاز MikroTik (تجريبية — لا يوجد ربط فعلي بجهاز حقيقي بعد)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.router, color: Color(0xFF1E88E5), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('حالة جهاز MikroTik', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('تجريبي', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'لم يتم ربط جهاز MikroTik حقيقي بعد — اربط جهازك لعرض بيانات الشبكة الحية هنا.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // إحصائيات الطباعة الحقيقية + رسم بياني
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final loading = snapshot.connectionState == ConnectionState.waiting;
                final stats = snapshot.data;
                final today = loading ? '...' : '${stats?['printedToday'] ?? 0}';
                final month = loading ? '...' : '${stats?['printedThisMonth'] ?? 0}';
                final last7 = (stats?['last7Days'] as List<int>?) ?? const [0, 0, 0, 0, 0, 0, 0];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('إحصائيات طباعة الكروت', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(child: _miniStat('اليوم', today, const Color(0xFF22D3EE))),
                          const SizedBox(width: 12),
                          Expanded(child: _miniStat('هذا الشهر', month, Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Sparkline(
                        values: last7.map((e) => e.toDouble()).toList(),
                        color: const Color(0xFF22D3EE),
                        height: 44,
                      ),
                      const SizedBox(height: 6),
                      const Text('آخر 7 أيام', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // أزرار الإجراءات
            const Text(
              'إجراءات سريعة',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildQuickAccessCard(
              context,
              title: 'توليد كروت',
              subtitle: 'إنشاء كروت جديدة لأي باقة',
              icon: Icons.add_card,
              onTap: () {
                final parent = context.findAncestorStateOfType<_HomePageState>();
                parent?.setState(() => parent._currentIndex = 3);
              },
            ),

            _buildQuickAccessCard(
              context,
              title: 'قائمة الكروت',
              subtitle: 'عرض كل الكروت وحالتها',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CardsListPage()),
                );
              },
            ),

            _buildQuickAccessCard(
              context,
              title: 'المراقبة',
              subtitle: 'متابعة المشتركين المتصلين',
              icon: Icons.monitor_heart_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MonitoringPage()),
                );
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
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
