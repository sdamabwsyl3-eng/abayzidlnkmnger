import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

/// صفحة مراقبة المشتركين.
/// ملاحظة مهمة: هذا التطبيق لا يملك حالياً أي ربط فعلي بجهاز MikroTik أو أي
/// راوتر حقيقي، لذلك لا توجد بيانات شبكة حيّة يمكن عرضها بصدق. هذه الشاشة
/// تعرض بيانات تجريبية (Demo) موسومة بوضوح لتوضيح شكل الواجهة المستقبلية،
/// بدل تلفيق أرقام استهلاك/اتصال وهمية وتقديمها كأنها حقيقية.
class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  static final List<_DemoSubscriber> _demoSubscribers = List.generate(6, (i) {
    final random = Random(i * 17 + 3);
    final names = ['أحمد محمد', 'فاطمة علي', 'عبدالله حسن', 'مريم آدم', 'عثمان بشير', 'سارة إبراهيم'];
    return _DemoSubscriber(
      name: names[i],
      ip: '192.168.88.${10 + i}',
      online: random.nextBool(),
      usageMb: 50 + random.nextInt(900),
    );
  });

  @override
  Widget build(BuildContext context) {
    final onlineCount = _demoSubscribers.where((s) => s.online).length;

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
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _summaryChip('متصل الآن', '$onlineCount', const Color(0xFF22D3EE)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryChip('إجمالي المشتركين', '${_demoSubscribers.length}', const Color(0xFF1E88E5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _demoSubscribers.length,
                itemBuilder: (ctx, i) {
                  final s = _demoSubscribers[i];
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
                          decoration: BoxDecoration(
                            color: s.online ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(s.ip, textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          s.online ? '${s.usageMb} MB' : 'غير متصل',
                          style: TextStyle(
                            color: s.online ? const Color(0xFF22D3EE) : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DemoSubscriber {
  final String name;
  final String ip;
  final bool online;
  final int usageMb;

  _DemoSubscriber({required this.name, required this.ip, required this.online, required this.usageMb});
}
