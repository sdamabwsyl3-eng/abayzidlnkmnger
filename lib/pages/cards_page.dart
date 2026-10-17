import 'package:flutter/material.dart';
import '../models/package_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late Future<List<PackageModel>> _packagesFuture;
  PackageModel? _selectedPackage;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _packagesFuture = SupabaseDataService.fetchPackages();
  }

  Future<void> _printCards() async {
    final selected = _selectedPackage;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر باقة أولاً')),
      );
      return;
    }

    final quantity = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: '10');
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('عدد الكروت', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1F2937),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text.trim())),
              child: const Text('طباعة'),
            ),
          ],
        );
      },
    );

    if (quantity == null || quantity <= 0 || quantity > 500) return;

    setState(() => _printing = true);
    try {
      final cards = await SupabaseDataService.generateCards(
        packageId: selected.id,
        quantity: quantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء ${cards.length} كرت لباقة "${selected.name}" بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر إنشاء الكروت: $e')),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
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
            'اختر باقة ثم أنشئ واطبع كروتها',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          FutureBuilder<List<PackageModel>>(
            future: _packagesFuture,
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
                  child: Text('تعذّر تحميل الباقات: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              }
              final packages = snapshot.data ?? const [];
              _selectedPackage ??= packages.isNotEmpty ? packages.first : null;

              return Column(
                children: packages.map((p) {
                  final selected = _selectedPackage?.id == p.id;
                  return AppCard(
                    title: p.name,
                    subtitle: p.subtitle,
                    trailing: _buildPrice(p.priceLabel),
                    color: selected ? const Color(0xFF1E88E5).withOpacity(0.25) : null,
                    onTap: () => setState(() => _selectedPackage = p),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printing ? null : _printCards,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _printing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.print),
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
