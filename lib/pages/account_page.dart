import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
                const Text(
                  'مدير النظام',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'admin@abayazeed.sd',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'مدير رئيسي',
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
          _buildInfoItem(Icons.calendar_today, 'تاريخ التحديث', '09 أكتوبر 2026'),
          _buildInfoItem(Icons.location_on, 'المنطقة', 'السودان — الخرطوم'),

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

          _buildSettingItem(Icons.notifications_outlined, 'الإشعارات', () {}),
          _buildSettingItem(Icons.privacy_tip_outlined, 'الخصوصية والأمان', () {}),
          _buildSettingItem(Icons.help_outline, 'حول التطبيق', () {}),
          _buildSettingItem(Icons.logout, 'تسجيل الخروج', () {
            Navigator.popUntil(context, (route) => route.isFirst);
          }, isDanger: true),

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
