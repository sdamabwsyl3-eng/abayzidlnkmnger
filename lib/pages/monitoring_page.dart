import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

/// صفحة مراقبة المشتركين.
/// ملاحظة مهمة: هذا التطبيق لا يملك حالياً أي ربط فعلي بجهاز MikroTik أو أي
/// راوتر حقيقي، لذلك لا توجد بيانات شبكة حيّة يمكن عرضها بصدق. هذه الشاشة
/// تعرض بيانات تجريبية (Demo) موسومة بوضوح لتوضيح شكل الواجهة المستقبلية،
/// بدل تلفيق أرقام استهلاك/اتصال وهمية وتقديمها كأنها حقيقية.
class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

enum _SubStatus { online, idle, offline }

class _MonitoringPageState extends State<MonitoringPage> {
  late final List<_DemoSubscriber> _subscribers;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final names = ['أحمد محمد', 'فاطمة علي', 'عبدالله حسن', 'مريم آدم', 'عثمان بشير', 'سارة إبراهيم', 'خالد الطيب', 'نور الهدى'];
    _subscribers = List.generate(names.length, (i) {
      final random = Random(i * 17 + 3);
      final status = _SubStatus.values[random.nextInt(3)];
      return _DemoSubscriber(
        name: names[i],
        ip: '192.168.88.${10 + i}',
        mac: '00:1A:3C:4D:${(10 + i).toRadixString(16).padLeft(2, '0').toUpperCase()}:${(i * 7 % 99).toRadixString(16).padLeft(2, '0').toUpperCase()}',
        status: status,
        usageMb: status == _SubStatus.offline ? 0 : 50 + random.nextInt(900),
      );
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(_SubStatus s) {
    switch (s) {
      case _SubStatus.online:
        return Colors.green;
      case _SubStatus.idle:
        return Colors.amber;
      case _SubStatus.offline:
        return Colors.grey;
    }
  }

  String _statusLabel(_SubStatus s) {
    switch (s) {
      case _SubStatus.online:
        return 'متصل';
      case _SubStatus.idle:
        return 'معلق';
      case _SubStatus.offline:
        return 'منقطع';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _subscribers.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.ip.contains(q) || s.mac.toLowerCase().contains(q);
    }).toList();

    final onlineCount = _subscribers.where((s) => s.status == _SubStatus.online).length;
    final idleCount = _subscribers.where((s) => s.status == _SubStatus.idle).length;
    final offlineCount = _subscribers.where((s) => s.status == _SubStatus.offline).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'مراقبة المشتركين', isOnline: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'بيانات تجريبية (Demo) — هذا التطبيق غير مرتبط بجهاز MikroTik حقيقي بعد، لذا لا توجد مراقبة فعلية للشبكة حالياً.',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.amber.shade200, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'بحث باسم المستخدم أو IP أو MAC',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(child: _summaryChip('متصل', '$onlineCount', Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryChip('معلق', '$idleCount', Colors.amber)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryChip('منقطع', '$offlineCount', Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('لا نتائج مطابقة', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final s = filtered[i];
                        final color = _statusColor(s.status);
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
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${s.ip}  •  ${s.mac}',
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _statusLabel(s.status),
                                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  if (s.status != _SubStatus.offline) ...[
                                    const SizedBox(height: 3),
                                    Text('${s.usageMb} MB', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _DemoSubscriber {
  final String name;
  final String ip;
  final String mac;
  final _SubStatus status;
  final int usageMb;

  _DemoSubscriber({
    required this.name,
    required this.ip,
    required this.mac,
    required this.status,
    required this.usageMb,
  });
}
