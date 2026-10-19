import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';

class CardsListPage extends StatefulWidget {
  const CardsListPage({super.key});

  @override
  State<CardsListPage> createState() => _CardsListPageState();
}

class _CardsListPageState extends State<CardsListPage> {
  late Future<List<CardModel>> _cardsFuture;
  String _filter = 'الكل';

  static const _filters = ['الكل', 'متاح', 'مباع', 'مستخدم'];

  @override
  void initState() {
    super.initState();
    _cardsFuture = SupabaseDataService.fetchMyCards();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'sold':
        return 'مباع';
      case 'used':
        return 'مستخدم';
      default:
        return 'متاح';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'sold':
        return const Color(0xFFA855F7);
      case 'used':
        return Colors.grey;
      default:
        return const Color(0xFF22D3EE);
    }
  }

  bool _matchesFilter(CardModel c) {
    if (_filter == 'الكل') return true;
    return _statusLabel(c.status) == _filter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'قائمة الكروت', isOnline: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  children: _filters.map((f) {
                    final sel = f == _filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(f, style: TextStyle(color: sel ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        selected: sel,
                        selectedColor: const Color(0xFF22D3EE),
                        backgroundColor: const Color(0xFF111827),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<CardModel>>(
                future: _cardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('تعذّر تحميل الكروت: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  final cards = (snapshot.data ?? const []).where(_matchesFilter).toList();
                  if (cards.isEmpty) {
                    return const Center(
                      child: Text('لا توجد كروت بعد', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: cards.length,
                    itemBuilder: (ctx, i) {
                      final c = cards[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _statusColor(c.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.credit_card, color: _statusColor(c.status), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    c.code,
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    c.packageName ?? '',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(c.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(c.status),
                                style: TextStyle(color: _statusColor(c.status), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
