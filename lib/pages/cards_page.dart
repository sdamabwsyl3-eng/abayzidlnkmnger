import 'package:flutter/material.dart';
import '../models/card_template_model.dart';
import '../models/package_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/card_widget.dart';
import 'cards_list_page.dart';
import 'credit_topup_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<PackageModel>> _packagesFuture;
  late Future<Map<String, int>> _availableFuture;
  late Future<int> _balanceFuture;
  late Future<List<CardTemplate>> _templatesFuture;
  PackageModel? _selectedPackage;
  CardTemplate? _selectedTemplate;
  int _quantity = 10;
  int _codeLength = 12;
  bool _creating = false;

  static const _codeLengthOptions = [4, 6, 8, 12];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _packagesFuture = SupabaseDataService.fetchPackages();
    _availableFuture = SupabaseDataService.fetchCardCountByPackage();
    _balanceFuture = SupabaseDataService.fetchCardCreditBalance();
    _templatesFuture = SupabaseDataService.fetchCardTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshCounts() {
    setState(() {
      _availableFuture = SupabaseDataService.fetchCardCountByPackage();
      _balanceFuture = SupabaseDataService.fetchCardCreditBalance();
    });
  }

  Future<void> _createCards() async {
    final selected = _selectedPackage;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر الفئة أولاً')),
      );
      return;
    }
    if (_quantity <= 0 || _quantity > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل كمية صحيحة (1 - 500)')),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      final cards = await SupabaseDataService.generateCards(
        packageId: selected.id,
        quantity: _quantity,
        codeLength: _codeLength,
        templateId: _selectedTemplate?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء ${cards.length} كرت لفئة "${selected.name}" بنجاح')),
      );
      _refreshCounts();
      _tabController.animateTo(0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر إنشاء الكروت: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const CommonHeader(connectionName: 'إدارة الكروت', isOnline: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'القائمة'),
                Tab(text: 'إنشاء كرت'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildListTab(),
              _buildCreateTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshCounts();
        await _availableFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'الكروت المتاحة حسب الفئة',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'عدد الكروت غير المستخدمة لكل فئة',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, int>>(
              future: _availableFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final counts = snapshot.data ?? const {};
                if (counts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('لا توجد كروت بعد', style: TextStyle(color: Colors.grey))),
                  );
                }
                return Column(
                  children: counts.entries.map((e) {
                    return AppCard(
                      title: e.key,
                      subtitle: '${e.value} كرت',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CardsListPage()),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CardsListPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('عرض كل الكروت'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FutureBuilder<int>(
            future: _balanceFuture,
            builder: (context, snapshot) {
              final balance = snapshot.data;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreditTopupPage()),
                        );
                        _refreshCounts();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('شحن رصيد'),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          balance != null ? '$balance' : '—',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text('رصيد الكروت المتاح', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Text('الفئة', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          FutureBuilder<List<PackageModel>>(
            future: _packagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final packages = snapshot.data ?? const [];
              _selectedPackage ??= packages.isNotEmpty ? packages.first : null;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PackageModel>(
                    value: _selectedPackage,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    items: packages.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} — ${p.priceLabel}'),
                      );
                    }).toList(),
                    onChanged: (p) => setState(() => _selectedPackage = p),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          const Text('المدة', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              _selectedPackage != null ? '${_selectedPackage!.durationDays} يوم' : '—',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          const Text('الكمية', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _quantity = (_quantity + 1).clamp(1, 500)),
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E88E5)),
                ),
                Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 500)),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('طول كود الكرت', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _codeLengthOptions.map((len) {
              final selected = _codeLength == len;
              return ChoiceChip(
                label: Text('$len رقم'),
                selected: selected,
                selectedColor: const Color(0xFF1E88E5),
                backgroundColor: const Color(0xFF1F2937),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey),
                onSelected: (_) => setState(() => _codeLength = len),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const Text('قالب التصميم (اختياري)', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          FutureBuilder<List<CardTemplate>>(
            future: _templatesFuture,
            builder: (context, snapshot) {
              final templates = snapshot.data ?? const [];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CardTemplate?>(
                    value: _selectedTemplate,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    hint: const Text('بدون قالب (تصميم افتراضي)', style: TextStyle(color: Colors.grey)),
                    items: [
                      const DropdownMenuItem<CardTemplate?>(
                        value: null,
                        child: Text('بدون قالب (تصميم افتراضي)'),
                      ),
                      ...templates.map((t) => DropdownMenuItem<CardTemplate?>(
                            value: t,
                            child: Text(t.name),
                          )),
                    ],
                    onChanged: (t) => setState(() => _selectedTemplate = t),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _creating ? null : _createCards,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.add_card),
              label: const Text('إنشاء الكرت', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
