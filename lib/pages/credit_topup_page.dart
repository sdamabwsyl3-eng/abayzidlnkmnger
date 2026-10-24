import 'package:flutter/material.dart';
import '../models/credit_topup_request_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';

/// شاشة شحن رصيد الكروت — تحويل بنكي يدوي، والموافقة من الأدمن فقط
/// (لا يوجد مسار داخل التطبيق لتفعيل الطلب ذاتياً).
class CreditTopupPage extends StatefulWidget {
  const CreditTopupPage({super.key});

  @override
  State<CreditTopupPage> createState() => _CreditTopupPageState();
}

class _CreditTopupPageState extends State<CreditTopupPage> {
  late Future<List<CreditTopupRequest>> _requestsFuture;
  final _creditsController = TextEditingController(text: '100');
  final _referenceController = TextEditingController();
  String _paymentMethod = 'بنكك';
  bool _sending = false;

  static const _paymentMethods = ['بنكك', 'تحويل بنكي', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _requestsFuture = SupabaseDataService.fetchMyTopupRequests();
  }

  @override
  void dispose() {
    _creditsController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _requestsFuture = SupabaseDataService.fetchMyTopupRequests();
    });
  }

  Future<void> _submit() async {
    final credits = int.tryParse(_creditsController.text.trim());
    if (credits == null || credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل عدد كروت صحيح')),
      );
      return;
    }
    if (_referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم/مرجع التحويل حتى يتحقق منه الأدمن')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await SupabaseDataService.requestCreditTopup(
        credits: credits,
        paymentMethod: _paymentMethod,
        referenceNote: _referenceController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الشحن — بانتظار موافقة الأدمن')),
      );
      _referenceController.clear();
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر إرسال الطلب: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const CommonHeader(connectionName: 'شحن رصيد الكروت', isOnline: true),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refresh();
                  await _requestsFuture;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'الشحن يتم بتحويل بنكي يدوي. اكتب رقم أو مرجع التحويل، '
                                'وسيراجع الأدمن الطلب ويضيف الرصيد بعد التأكد منه — لا '
                                'يوجد تفعيل تلقائي من داخل التطبيق.',
                                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.5),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('عدد الكروت المطلوب شحنها', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _creditsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1F2937),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('طريقة التحويل', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _paymentMethod,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1F2937),
                            style: const TextStyle(color: Colors.white),
                            items: _paymentMethods
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (m) => setState(() => _paymentMethod = m ?? _paymentMethod),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('رقم/مرجع التحويل', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _referenceController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'مثال: رقم إشعار التحويل',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1F2937),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _sending ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.send),
                          label: const Text('إرسال طلب الشحن'),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text('طلباتي السابقة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      FutureBuilder<List<CreditTopupRequest>>(
                        future: _requestsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final requests = snapshot.data ?? const [];
                          if (requests.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('لا توجد طلبات شحن بعد', style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return Column(
                            children: requests.map((r) => _requestTile(r)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestTile(CreditTopupRequest r) {
    final Color color;
    final String label;
    switch (r.status) {
      case 'approved':
        color = const Color(0xFF22C55E);
        label = 'تمت الموافقة';
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        label = 'مرفوض';
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'قيد المراجعة';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${r.requestedCredits} كرت — ${r.paymentMethod}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(r.referenceNote, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
