import 'package:flutter/material.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';
import '../widgets/bar_chart.dart';
import '../widgets/donut_chart.dart';

/// شاشة الإحصائيات والتقارير — كل الأرقام هنا حقيقية من كروت المشغّل في
/// Supabase (تواريخ الإنشاء وتوزيعها حسب الفئة)، وليست بيانات استهلاك شبكة
/// حيّة لأن التطبيق لا يملك بعد ربطاً فعلياً بجهاز MikroTik.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

enum _Range { day, week, month, year }

class _StatisticsPageState extends State<StatisticsPage> {
  _Range _range = _Range.week;
  late Future<List<DateTime>> _datesFuture;
  late Future<Map<String, int>> _byPackageFuture;

  static const _packageColors = [
    Color(0xFF1E88E5),
    Color(0xFFEF4444),
    Color(0xFF22D3EE),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFF22C55E),
  ];

  @override
  void initState() {
    super.initState();
    _datesFuture = SupabaseDataService.fetchCardCreationDates();
    _byPackageFuture = SupabaseDataService.fetchCardCountByPackage();
  }

  ({List<double> values, List<String> labels, int total}) _bucket(List<DateTime> dates) {
    final now = DateTime.now();
    switch (_range) {
      case _Range.day:
        final values = List<double>.generate(24, (h) {
          return dates.where((d) => d.year == now.year && d.month == now.month && d.day == now.day && d.hour == h).length.toDouble();
        });
        final labels = List<String>.generate(24, (h) => h % 4 == 0 ? '$h' : '');
        return (values: values, labels: labels, total: values.fold(0.0, (a, b) => a + b).toInt());
      case _Range.week:
        final labels = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
        final values = List<double>.generate(7, (i) {
          final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
          return dates.where((d) => d.year == day.year && d.month == day.month && d.day == day.day).length.toDouble();
        });
        final weekdayLabels = List<String>.generate(7, (i) {
          final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
          return labels[day.weekday % 7];
        });
        return (values: values, labels: weekdayLabels, total: values.fold(0.0, (a, b) => a + b).toInt());
      case _Range.month:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final values = List<double>.generate(daysInMonth, (i) {
          final day = i + 1;
          return dates.where((d) => d.year == now.year && d.month == now.month && d.day == day).length.toDouble();
        });
        final labels = List<String>.generate(daysInMonth, (i) => (i + 1) % 5 == 0 ? '${i + 1}' : '');
        return (values: values, labels: labels, total: values.fold(0.0, (a, b) => a + b).toInt());
      case _Range.year:
        const monthNames = ['ينا', 'فبر', 'مار', 'أبر', 'ماي', 'يون', 'يول', 'أغس', 'سبت', 'أكت', 'نوف', 'ديس'];
        final values = List<double>.generate(12, (m) {
          return dates.where((d) => d.year == now.year && d.month == m + 1).length.toDouble();
        });
        return (values: values, labels: monthNames, total: values.fold(0.0, (a, b) => a + b).toInt());
    }
  }

  String _rangeLabel(_Range r) {
    switch (r) {
      case _Range.day:
        return 'اليوم';
      case _Range.week:
        return 'الأسبوع';
      case _Range.month:
        return 'الشهر';
      case _Range.year:
        return 'السنة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'الإحصائيات والتقارير', isOnline: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: _Range.values.map((r) {
                  final sel = r == _range;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _range = r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF1E88E5) : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _rangeLabel(r),
                            style: TextStyle(color: sel ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FutureBuilder<List<DateTime>>(
                      future: _datesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final dates = snapshot.data ?? const [];
                        final b = _bucket(dates);
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${b.total}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  const Text('كروت تم إنشاؤها', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SimpleBarChart(values: b.values, labels: b.labels, color: const Color(0xFF22D3EE)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('توزيع الكروت حسب الفئة', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, int>>(
                      future: _byPackageFuture,
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
                            child: Center(child: Text('لا توجد بيانات بعد', style: TextStyle(color: Colors.grey))),
                          );
                        }
                        final entries = counts.entries.toList();
                        final slices = List.generate(entries.length, (i) {
                          return DonutSlice(
                            label: entries[i].key,
                            value: entries[i].value,
                            color: _packageColors[i % _packageColors.length],
                          );
                        });
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: DonutChart(slices: slices),
                        );
                      },
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
}
