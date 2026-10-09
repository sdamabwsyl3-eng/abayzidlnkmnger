import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CommonHeader(
            connectionName: 'المتجر والخدمات',
            isOnline: true,
          ),
          const SizedBox(height: 20),

          const Text(
            'متجر الخدمات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'باقات Starlink ومستلزمات الشبكات',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          const Text(
            'باقات Starlink',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            title: 'Starlink — 3 أشهر',
            subtitle: 'سرعة عالية — تجوال دولي',
            trailing: _buildPrice('100 \$'),
            onTap: () {},
          ),

          AppCard(
            title: 'Starlink — 6 أشهر',
            subtitle: 'الأكثر طلباً — توفير 17%',
            trailing: _buildPrice('300 \$'),
            onTap: () {},
          ),

          AppCard(
            title: 'Starlink — سنة كاملة',
            subtitle: 'أفضل قيمة — توفير 33%',
            trailing: _buildPrice('400 \$'),
            color: Colors.green.withOpacity(0.1),
            onTap: () {},
          ),

          const SizedBox(height: 30),

          const Text(
            'أجهزة ومستلزمات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            title: 'طابعة حرارية Sunmi',
            subtitle: 'طباعة كروت وايصالات — لاسلكية',
            trailing: _buildPrice('180 \$'),
            onTap: () {},
          ),

          AppCard(
            title: 'جهاز MikroTik hAP',
            subtitle: 'إدارة الشبكة محلياً',
            trailing: _buildPrice('95 \$'),
            onTap: () {},
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('طلب شراء', style: TextStyle(fontSize: 16)),
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
