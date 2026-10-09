import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';

class SolutionsPage extends StatelessWidget {
  const SolutionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CommonHeader(
            connectionName: 'حلول ومساعدة',
            isOnline: true,
          ),
          const SizedBox(height: 20),

          const Text(
            'حلول وأدلة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'دروس وأدلة استخدام النظام',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          AppCard(
            title: 'كيفية ربط جهاز MikroTik',
            subtitle: 'خطوة بخطوة — إعداد الاتصال الأول',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {},
          ),

          AppCard(
            title: 'إدارة العملاء والباقات',
            subtitle: 'إنشاء وتعديل وحذف باقات الإنترنت',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {},
          ),

          AppCard(
            title: 'طباعة الكروت الحرارية',
            subtitle: 'إعداد طابعة Sunmi وطباعة الكروت',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {},
          ),

          AppCard(
            title: 'حل مشاكل الاتصال',
            subtitle: 'دليل استكشاف الأخطاء وإصلاحها',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {},
          ),

          AppCard(
            title: 'الأسئلة الشائعة',
            subtitle: 'إجابات على الأسئلة الأكثر تكراراً',
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {},
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'تحتاج مساعدة إضافية؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'تواصل مع الدعم الفني: support@abayazeed.sd',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
