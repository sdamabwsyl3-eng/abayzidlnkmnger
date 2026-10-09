import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CommonHeader(
            connectionName: 'إدارة الكروت والباقات',
            isOnline: true,
          ),
          const SizedBox(height: 20),

          const Text(
            'الباقات المتاحة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أنشئ واطبع كروت الشبكة بسهولة',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          AppCard(
            title: 'باقة أسبوعية',
            subtitle: 'صلاحية 7 أيام — سرعة غير محدودة',
            trailing: _buildPrice('50 SDG'),
            onTap: () {},
          ),

          AppCard(
            title: 'باقة شهرية — أساسية',
            subtitle: 'صلاحية 30 يوم — 100 جيجا',
            trailing: _buildPrice('200 SDG'),
            onTap: () {},
          ),

          AppCard(
            title: 'باقة شهرية — متقدمة',
            subtitle: 'صلاحية 30 يوم — سرعة غير محدودة',
            trailing: _buildPrice('350 SDG'),
            onTap: () {},
          ),

          AppCard(
            title: 'باقة سنوية',
            subtitle: 'أفضل قيمة — توفير 25%',
            trailing: _buildPrice('3,500 SDG'),
            color: const Color(0xFF1E88E5).withOpacity(0.15),
            onTap: () {},
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.print),
              label: const Text('طباعة كروت جديدة', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice(String price) {
    return Text(
      price,
      style: const TextStyle(
        color: Color(0xFF1E88E5),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
