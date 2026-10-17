import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const String _defaultIp = '192.168.88.1';
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('last_email') ?? '';
      _ipController.text = prefs.getString('last_ip') ?? _defaultIp;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', _emailController.text.trim());
    await prefs.setString('last_ip', _ipController.text.trim());
  }

  bool _isValidIp(String ip) {
    if (!_ipRegex.hasMatch(ip)) return false;
    final parts = ip.split('.');
    return parts.every((part) => int.parse(part) <= 255);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _saveData();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(routerIp: _ipController.text.trim())),
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'تعذّر الاتصال، تحقق من الإنترنت وحاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2B48),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1E88E5), width: 3),
                      color: const Color(0xFF1E88E5).withOpacity(0.1),
                    ),
                    child: const Icon(Icons.router, color: Color(0xFF1E88E5), size: 50),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'أبا يزيد لنك منجر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'منظومة إدارة شبكات ميكروتك وطباعة الكروت الحرارية',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'البريد الإلكتروني',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E88E5)),
                          ),
                          textDirection: TextDirection.ltr,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                            if (!_emailRegex.hasMatch(value)) return 'صيغة البريد الإلكتروني غير صحيحة';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'كلمة المرور',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF1E88E5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          textDirection: TextDirection.ltr,
                          validator: (v) => (v ?? '').length < 6 ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'عنوان IP للراوتر',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ipController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '192.168.88.1',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _ipController.text = _defaultIp;
                                  },
                                  child: const Text(
                                    'افتراضي',
                                    style: TextStyle(color: Color(0xFF1E88E5), fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.settings_ethernet, color: Color(0xFF1E88E5)),
                              ],
                            ),
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.url,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'يرجى إدخال عنوان IP للراوتر';
                            if (!_isValidIp(value)) return 'صيغة عنوان IP غير صحيحة';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'دخول إلى غرفة العمليات (NOC)',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SignupPage()),
                                    ),
                            child: const Text(
                              'ما عندك حساب؟ أنشئ حساب جديد',
                              style: TextStyle(color: Color(0xFF1E88E5), fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
