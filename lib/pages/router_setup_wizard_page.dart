import 'package:flutter/material.dart';
import '../services/router_os_service.dart';
import '../services/supabase_data_service.dart';
import '../widgets/common_header.dart';

/// معالج إعداد راوتر MikroTik جديد — "مسح كامل" (fresh wipe) هو الوضع
/// الافتراضي والمفضّل حسب قرار المشغّل، وهو خطوة لا رجعة فيها (تمسح إعدادات
/// الراوتر الحالية وتفصل أي مشتركين متصلين حالياً)، لذلك يتطلب تأكيداً
/// صريحاً من المستخدم قبل تنفيذه ولا يُنفَّذ تلقائياً.
///
/// بيانات دخول الراوتر تُستخدم هنا فقط لفتح اتصال RouterOS API واختبار
/// الوصول، ولا تُرسَل أو تُخزَّن في Supabase على الإطلاق.
class RouterSetupWizardPage extends StatefulWidget {
  const RouterSetupWizardPage({super.key});

  @override
  State<RouterSetupWizardPage> createState() => _RouterSetupWizardPageState();
}

enum _SetupMode { freshWipe, adoptExisting }

class _RouterSetupWizardPageState extends State<RouterSetupWizardPage> {
  int _step = 0;
  _SetupMode _mode = _SetupMode.freshWipe;

  final _addressController = TextEditingController();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _testing = false;
  bool _connected = false;
  String? _testError;
  Map<String, String>? _identity;

  bool _wipeAcknowledged = false;
  bool _saving = false;

  @override
  void dispose() {
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final address = _addressController.text.trim();
    if (address.isEmpty || _passwordController.text.isEmpty && _usernameController.text.trim() != 'admin') {
      // كلمة مرور فارغة مقبولة (إعداد افتراضي من المصنع)، لكن العنوان لازم يكون موجود
    }
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل عنوان IP الخاص بالراوتر')),
      );
      return;
    }

    setState(() {
      _testing = true;
      _testError = null;
      _connected = false;
    });

    final client = RouterOsService(
      host: address,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    try {
      await client.connect();
      final id = await client.identity();
      if (!mounted) return;
      setState(() {
        _connected = true;
        _identity = id;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _testError = e is RouterOsException ? e.message : 'تعذّر الاتصال: $e';
      });
    } finally {
      await client.close();
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _finishSetup() async {
    setState(() => _saving = true);
    try {
      await SupabaseDataService.createDevice(
        name: _nameController.text.trim().isEmpty ? 'راوتر ${_addressController.text.trim()}' : _nameController.text.trim(),
        setupMode: _mode == _SetupMode.freshWipe ? 'fresh_wipe' : 'adopt_existing',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الجهاز. الربط الفعلي للمراقبة الحيّة قيد التنفيذ.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر حفظ الجهاز: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
            const CommonHeader(connectionName: 'تجهيز راوتر جديد', isOnline: true),
            _StepIndicator(step: _step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepMode();
      case 1:
        return _stepConnect();
      case 2:
        return _stepConfirmWipe();
      default:
        return _stepDone();
    }
  }

  Widget _stepMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('اختر طريقة الإعداد', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'الوضع الموصى به هو "برمجة جديدة (مسح كامل)" — يضمن إعداداً نظيفاً '
          'بدون أي تعارض مع ضبط سابق للراوتر.',
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 20),
        _modeTile(
          mode: _SetupMode.freshWipe,
          title: 'برمجة جديدة (مسح كامل) — موصى به',
          subtitle: 'يمسح إعدادات الراوتر الحالية بالكامل ويبدأ من جديد. يفصل أي مشتركين متصلين حالياً.',
          icon: Icons.restart_alt,
        ),
        const SizedBox(height: 10),
        _modeTile(
          mode: _SetupMode.adoptExisting,
          title: 'تبنّي الإعداد الحالي (بدون مسح)',
          subtitle: 'يحتفظ بإعدادات الراوتر كما هي ويضيف ربط التطبيق فوقها فقط.',
          icon: Icons.integration_instructions_outlined,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'اسم الجهاز (اختياري)',
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1F2937),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        _nextButton(onPressed: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _modeTile({required _SetupMode mode, required String title, required String subtitle, required IconData icon}) {
    final selected = _mode == mode;
    return InkWell(
      onTap: () => setState(() => _mode = mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFF1E88E5) : Colors.white12, width: selected ? 2 : 1),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: selected ? const Color(0xFF1E88E5) : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.right),
                ],
              ),
            ),
            Radio<_SetupMode>(
              value: mode,
              groupValue: _mode,
              onChanged: (m) => setState(() => _mode = m ?? _mode),
              activeColor: const Color(0xFF1E88E5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepConnect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('بيانات اتصال الراوتر', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'هذه بيانات دخول المدير (Admin) على الراوتر نفسه — وليست بيانات كرت '
          'الهوتسبوت. تبقى محفوظة على جهازك فقط ولا تُرفع لأي خادم.',
          style: TextStyle(color: Colors.grey, fontSize: 12.5, height: 1.5),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 18),
        _field(_addressController, 'عنوان IP', hint: '192.168.88.1'),
        const SizedBox(height: 14),
        _field(_usernameController, 'اسم المستخدم'),
        const SizedBox(height: 14),
        _field(_passwordController, 'كلمة المرور', obscure: true),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _testing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.wifi_tethering),
            label: const Text('اختبار الاتصال'),
          ),
        ),
        if (_connected)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(
                'تم الاتصال بنجاح${_identity?['name'] != null ? ' — ${_identity!['name']}' : ''}',
                style: const TextStyle(color: Color(0xFF22C55E)),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        if (_testError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(_testError!, style: const TextStyle(color: Color(0xFFEF4444)), textAlign: TextAlign.right),
            ),
          ),
        const SizedBox(height: 24),
        _nextButton(
          onPressed: _connected ? () => setState(() => _step = 2) : null,
          label: 'متابعة',
        ),
      ],
    );
  }

  Widget _stepConfirmWipe() {
    final isWipe = _mode == _SetupMode.freshWipe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isWipe ? 'تأكيد المسح الكامل' : 'تأكيد الربط',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (isWipe)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'هذه الخطوة ستمسح كل إعدادات الراوتر الحالية وتفصل أي مشتركين '
                    'متصلين الآن. تأكد أنك جاهز قبل المتابعة — هذا الإجراء لا رجعة فيه.',
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, height: 1.5),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'سيتم ربط التطبيق بإعدادات الراوتر الحالية كما هي بدون أي تغيير عليها.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            textAlign: TextAlign.right,
          ),
        const SizedBox(height: 16),
        if (isWipe)
          CheckboxListTile(
            value: _wipeAcknowledged,
            onChanged: (v) => setState(() => _wipeAcknowledged = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFFEF4444),
            title: const Text('أفهم أن هذا الإجراء سيمسح إعدادات الراوتر ولا يمكن التراجع عنه',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        const SizedBox(height: 16),
        const Text(
          'ملاحظة: التنفيذ الفعلي لأمر المسح على الراوتر سيتم تفعيله لاحقاً بعد اختبار '
          'كامل على جهاز حقيقي؛ هذه الخطوة الآن تسجّل الجهاز وتحضّر الربط.',
          style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 24),
        _nextButton(
          onPressed: (!isWipe || _wipeAcknowledged) ? () => setState(() => _step = 3) : null,
          label: 'تأكيد والمتابعة',
        ),
      ],
    );
  }

  Widget _stepDone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 48),
        const SizedBox(height: 12),
        const Text('جاهز لحفظ الجهاز', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'سيُسجَّل الجهاز في حسابك، ويمكنك متابعته من شاشة إدارة MikroTik.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 24),
        _nextButton(onPressed: _saving ? null : _finishSetup, label: 'حفظ الجهاز', loading: _saving),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {String? hint, bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _nextButton({required VoidCallback? onPressed, String label = 'متابعة', bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Text(label),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    const labels = ['الوضع', 'الاتصال', 'التأكيد', 'الإنهاء'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: List.generate(labels.length, (i) {
          final active = i <= step;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF1E88E5) : Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i], style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 10)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
