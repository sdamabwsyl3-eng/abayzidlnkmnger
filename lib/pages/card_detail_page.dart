import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/card_model.dart';
import '../widgets/common_header.dart';

class CardDetailPage extends StatelessWidget {
  final CardModel card;

  const CardDetailPage({super.key, required this.card});

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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: card.code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ كود الكرت')),
    );
  }

  Future<void> _printCard(BuildContext context) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('ابا يزيد لنك منجر', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text(card.packageName ?? '', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),
                pw.Text(card.code, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                pw.SizedBox(height: 16),
                pw.Text('تاريخ الإصدار: ${_formatDate(card.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                if (card.expiresAt != null)
                  pw.Text('تاريخ الانتهاء: ${_formatDate(card.expiresAt!)}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(card.status);
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'تفاصيل الكرت', isOnline: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.25), const Color(0xFF111827)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          const Text('كود الكرت', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 10),
                          Text(
                            card.code,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(card.status),
                              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          _detailRow('الفئة', card.packageName ?? '—'),
                          const Divider(color: Colors.white12, height: 20),
                          _detailRow('المدة', card.packageDurationDays != null ? '${card.packageDurationDays} يوم' : '—'),
                          const Divider(color: Colors.white12, height: 20),
                          _detailRow('تاريخ الإنشاء', _formatDate(card.createdAt)),
                          if (card.expiresAt != null) ...[
                            const Divider(color: Colors.white12, height: 20),
                            _detailRow('تاريخ الانتهاء', _formatDate(card.expiresAt!)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _copyCode(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text('نسخ الكود'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _printCard(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('طباعة الكرت'),
                      ),
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

  Widget _detailRow(String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
