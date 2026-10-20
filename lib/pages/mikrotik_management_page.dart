import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';
import 'cards_list_page.dart';
import 'monitoring_page.dart';
import 'settings_page.dart';

/// مركز إدارة MikroTik: نقطة دخول موحّدة لكل شاشات إدارة الشبكة والكروت.
/// حالة الجهاز هنا تجريبية لأن التطبيق لا يملك بعد ربطاً فعلياً بجهاز
/// MikroTik حقيقي؛ الإعدادات والشاشات المرتبطة بالبيانات الحقيقية (الكروت)
/// تعمل فعلياً على قاعدة البيانات.
class MikrotikManagementPage extends StatelessWidget {
  const MikrotikManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'إدارة MikroTik', isOnline: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.router, color: Color(0xFF1E88E5), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('MikroTik', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text('غير متصل بعد', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    AppCard(
                      title: 'المستخدمون النشطون',
                      subtitle: 'متابعة المشتركين المتصلين بالشبكة',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MonitoringPage()),
                      ),
                    ),
                    AppCard(
                      title: 'إعدادات Hotspot',
                      subtitle: 'إعداد صفحة الدخول وخيارات الشبكة اللاسلكية',
                      onTap: () => _comingSoon(context, 'إعدادات Hotspot'),
                    ),
                    AppCard(
                      title: 'قوائم الكروت',
                      subtitle: 'عرض كل الكروت وحالتها',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CardsListPage()),
                      ),
                    ),
                    AppCard(
                      title: 'إعدادات الشبكة',
                      subtitle: 'عنوان الجهاز وبيانات الاتصال',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                    ),
                    AppCard(
                      title: 'سجل الأحداث',
                      subtitle: 'سجل العمليات الأخيرة على الحساب',
                      onTap: () => _comingSoon(context, 'سجل الأحداث'),
                    ),
                    AppCard(
                      title: 'إعادة تشغيل الجهاز',
                      subtitle: 'يتطلب ربط جهاز MikroTik حقيقي أولاً',
                      onTap: () => _comingSoon(context, 'إعادة تشغيل الجهاز', note: 'هذه الميزة تحتاج ربطاً فعلياً بجهاز MikroTik قبل أن تعمل.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String title, {String? note}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(note ?? '$title — قريباً')),
    );
  }
}
