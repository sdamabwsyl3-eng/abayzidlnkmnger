import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أبا يزيد لنك منجر',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2B48),
          primary: const Color(0xFF0F2B48),
          onPrimary: Colors.white,
          secondary: const Color(0xFF1E88E5),
          background: const Color(0xFFF5F7FA),
        ),
        useMaterial3: true,
        fontFamily: 'IBMPlexSansArabic', // ✅ تم التعديل
        scaffoldBackgroundColor: const Color(0xFF0F2B48),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
