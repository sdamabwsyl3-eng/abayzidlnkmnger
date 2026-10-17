import 'package:flutter/material.dart';
import '../models/store_item_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<StoreItemModel>> _itemsFuture;
  StoreItemModel? _selectedItem;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = SupabaseDataService.fetchStoreItems();
  }

  Future<void> _order() async {
    final item = _selectedItem;
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر عنصراً من المتجر أولاً')),
      );
      return;
    }
    setState(() => _ordering = true);
    try {
      await SupabaseDataService.createStoreOrder(itemId: item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال طلب شراء "${item.name}" بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر إرسال الطلب: $e')),
      );
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

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

          FutureBuilder<List<StoreItemModel>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('تعذّر تحميل المتجر: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              }
              final items = snapshot.data ?? const [];
              final starlink = items.where((i) => i.category == 'starlink').toList();
              final devices = items.where((i) => i.category != 'starlink').toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (starlink.isNotEmpty) ...[
                    const Text(
                      'باقات Starlink',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...starlink.map((i) => _itemCard(i)),
                    const SizedBox(height: 30),
                  ],
                  if (devices.isNotEmpty) ...[
                    const Text(
                      'أجهزة ومستلزمات',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...devices.map((i) => _itemCard(i)),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _ordering ? null : _order,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _ordering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.shopping_cart),
              label: const Text('طلب شراء', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(StoreItemModel item) {
    final selected = _selectedItem?.id == item.id;
    return AppCard(
      title: item.name,
      subtitle: item.subtitle,
      trailing: _buildPrice(item.priceLabel),
      color: selected ? Colors.green.withOpacity(0.2) : null,
      onTap: () => setState(() => _selectedItem = item),
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
