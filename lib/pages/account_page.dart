import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/operator_profile_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import 'login_page.dart';
import 'mikrotik_management_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<OperatorProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupabaseDataService.fetchMyProfile();
  }

  String get _displayName {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = (user?.userMetadata?['full_name'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return user?.email?.split('@').first ?? 'مستخدم أبا يزيد';
  }

  String get _email => Supabase.instance.client.auth.currentUser?.email ?? '';

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
          const CommonHeader(
            connectionName: 'حساب المستخدم',
            isOnline: true,
          ),
          const SizedBox(height: 30),

          // صورة الملف الشخصي والاسم
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF1E88E5),
                    size: 45,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'حساب موثّق',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // معلومات النظام
          const Text(
            'معلومات النظام',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoItem(Icons.info_outline, 'اسم التطبيق', 'أبا يزيد لنك منجر'),
          _buildInfoItem(Icons.code, 'الإصدار', '4.2.0'),
          FutureBuilder<OperatorProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final region = snapshot.data?.region;
              return _buildInfoItem(
                Icons.location_on,
                'المنطقة',
                (region != null && region.isNotEmpty) ? region : 'غير محددة',
              );
            },
          ),

          const SizedBox(height: 30),

          // إعدادات
          const Text(
            'الإعدادات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(Icons.router_outlined, 'إدارة MikroTik', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MikrotikManagementPage()),
            );
          }),
          _buildSettingItem(Icons.bar_chart_outlined, 'الإحصائيات والتقارير', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          }),
          _buildSettingItem(Icons.settings_outlined, 'الإعدادات', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          }),
          _buildSettingItem(Icons.help_outline, 'حول التطبيق', () {}),
          _buildSettingItem(Icons.logout, 'تسجيل الخروج', _logout, isDanger: true),

          const SizedBox(height: 40),

          const Center(
            child: Text(
              '© 2026 أبا يزيد — جميع الحقوق محفوظة',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              color: isDanger ? Colors.red : const Color(0xFF1E88E5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDanger ? Colors.red : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
