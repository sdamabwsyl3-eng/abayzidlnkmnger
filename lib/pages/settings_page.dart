import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_header.dart';

/// شاشة الإعدادات: إعدادات الاتصال بجهاز MikroTik (تُحفظ محلياً على الجهاز
/// فقط — لا يوجد بعد اتصال فعلي بجهاز حقيقي من هذا التطبيق)، وإعدادات
/// التطبيق العامة (تحديث تلقائي، إشعارات، لغة)، ومعلومات التطبيق.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _autoUpdate = true;
  bool _notifications = true;
  bool _loading = true;

  static const _kAddress = 'mikrotik_address';
  static const _kUsername = 'mikrotik_username';
  static const _kPassword = 'mikrotik_password';
  static const _kAutoUpdate = 'app_auto_update';
  static const _kNotifications = 'app_notifications';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _addressController.text = prefs.getString(_kAddress) ?? '192.168.88.1';
      _usernameController.text = prefs.getString(_kUsername) ?? '';
      _passwordController.text = prefs.getString(_kPassword) ?? '';
      _autoUpdate = prefs.getBool(_kAutoUpdate) ?? true;
      _notifications = prefs.getBool(_kNotifications) ?? true;
      _loading = false;
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAddress, _addressController.text.trim());
    await prefs.setString(_kUsername, _usernameController.text.trim());
    await prefs.setString(_kPassword, _passwordController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ إعدادات الاتصال على هذا الجهاز')),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CommonHeader(connectionName: 'الإعدادات', isOnline: true),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('إعدادات الاتصال', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                            'بيانات الاتصال بجهاز MikroTik — تُحفظ على جهازك فقط، ولا يوجد بعد ربط فعلي بجهاز حقيقي.',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          _field('عنوان MikroTik', _addressController, hint: '192.168.88.1'),
                          const SizedBox(height: 12),
                          _field('اسم المستخدم', _usernameController, hint: 'admin'),
                          const SizedBox(height: 12),
                          _field('كلمة المرور', _passwordController, obscureToggle: true),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveConnection,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('اختيار الاتصال'),
                            ),
                          ),
                          const SizedBox(height: 32),

                          const Text('إعدادات التطبيق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _switchRow(
                            'التحديث التلقائي للبيانات',
                            _autoUpdate,
                            (v) {
                              setState(() => _autoUpdate = v);
                              _saveToggle(_kAutoUpdate, v);
                            },
                          ),
                          _switchRow(
                            'الإشعارات',
                            _notifications,
                            (v) {
                              setState(() => _notifications = v);
                              _saveToggle(_kNotifications, v);
                            },
                          ),
                          _infoRow('اللغة', 'العربية'),
                          const SizedBox(height: 32),

                          const Text('معلومات التطبيق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _infoRow('الإصدار', '4.2.0'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {String? hint, bool obscureToggle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureToggle && _obscurePassword,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1F2937),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            suffixIcon: obscureToggle
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF1E88E5)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
