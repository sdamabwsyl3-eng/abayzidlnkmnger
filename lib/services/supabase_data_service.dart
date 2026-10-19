import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/card_model.dart';
import '../models/operator_profile_model.dart';
import '../models/package_model.dart';
import '../models/store_item_model.dart';

/// طبقة وصول موحّدة لبيانات أبا يزيد لنك منجر الحقيقية في Supabase
/// (الملف الشخصي، الباقات، الكروت، المتجر) بدل البيانات الثابتة بالكود.
class SupabaseDataService {
  static SupabaseClient get _client => Supabase.instance.client;

  static String get _uidOrThrow {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    return uid;
  }

  /// يجلب الملف الشخصي لمشغّل الشبكة الحالي.
  static Future<OperatorProfile?> fetchMyProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (row == null) return null;
    return OperatorProfile.fromJson(row);
  }

  /// يجلب باقات الكروت الخاصة بالمشغّل الحالي، وينشئ الباقات الافتراضية
  /// الأربع تلقائياً أول مرة إذا كانت قائمته فاضية.
  static Future<List<PackageModel>> fetchPackages() async {
    final uid = _uidOrThrow;
    var rows = await _client
        .from('packages')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: true);

    if ((rows as List).isEmpty) {
      await _client.from('packages').insert([
        {'owner_id': uid, 'name': 'باقة أسبوعية', 'subtitle': 'صلاحية 7 أيام — سرعة غير محدودة', 'duration_days': 7, 'price': 50, 'currency': 'SDG'},
        {'owner_id': uid, 'name': 'باقة شهرية — أساسية', 'subtitle': 'صلاحية 30 يوم — 100 جيجا', 'duration_days': 30, 'price': 200, 'currency': 'SDG'},
        {'owner_id': uid, 'name': 'باقة شهرية — متقدمة', 'subtitle': 'صلاحية 30 يوم — سرعة غير محدودة', 'duration_days': 30, 'price': 350, 'currency': 'SDG'},
        {'owner_id': uid, 'name': 'باقة سنوية', 'subtitle': 'أفضل قيمة — توفير 25%', 'duration_days': 365, 'price': 3500, 'currency': 'SDG'},
      ]);
      rows = await _client
          .from('packages')
          .select()
          .eq('owner_id', uid)
          .order('created_at', ascending: true);
    }

    return (rows as List<dynamic>).map((r) => PackageModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// يولّد كروتاً جديدة لباقة معيّنة بأكواد فريدة (محاكاة "الطباعة").
  static Future<List<CardModel>> generateCards({
    required String packageId,
    required int quantity,
  }) async {
    final uid = _uidOrThrow;
    final random = Random.secure();
    final rows = List.generate(quantity, (_) {
      final code = List.generate(12, (_) => random.nextInt(10)).join();
      final grouped = '${code.substring(0, 4)}-${code.substring(4, 8)}-${code.substring(8, 12)}';
      return {
        'owner_id': uid,
        'package_id': packageId,
        'code': grouped,
        'status': 'unused',
      };
    });
    final inserted = await _client.from('cards').insert(rows).select();
    return (inserted as List<dynamic>).map((r) => CardModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// إحصائيات لوحة التحكم: عدد الكروت المفعّلة (المباعة/المستخدمة)، عدد
  /// الباقات غير المستخدمة (الرصيد المتاح)، وعدد الكروت المطبوعة اليوم
  /// وهذا الشهر، إضافة لعدد الكروت المطبوعة يومياً في آخر 7 أيام (لرسم
  /// بياني صغير). كل الأرقام هنا حقيقية من جدول cards، وليست بيانات شبكة
  /// حيّة — تلك تحتاج ربط فعلي بجهاز MikroTik (غير متاح هنا).
  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    final uid = _uidOrThrow;
    final cards = await _client.from('cards').select('status, created_at').eq('owner_id', uid);
    final packages = await _client.from('packages').select('id').eq('owner_id', uid);

    final cardRows = (cards as List<dynamic>).cast<Map<String, dynamic>>();
    final dates = cardRows.map((c) => DateTime.parse(c['created_at'] as String).toLocal()).toList();

    final activeClients = cardRows.where((c) => c['status'] != 'unused').length;
    final unusedCards = cardRows.where((c) => c['status'] == 'unused').length;

    final today = DateTime.now();
    final printedToday = dates.where((d) => d.year == today.year && d.month == today.month && d.day == today.day).length;
    final printedThisMonth = dates.where((d) => d.year == today.year && d.month == today.month).length;

    final last7Days = List<int>.generate(7, (i) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      return dates.where((d) => d.year == day.year && d.month == day.month && d.day == day.day).length;
    });

    return {
      'activeClients': activeClients,
      'activePackages': (packages as List).length,
      'printedToday': printedToday,
      'unusedCards': unusedCards,
      'printedThisMonth': printedThisMonth,
      'last7Days': last7Days,
    };
  }

  /// يجلب كل الكروت الخاصة بالمشغّل الحالي (الأحدث أولاً) مع اسم باقة كل كرت.
  static Future<List<CardModel>> fetchMyCards() async {
    final uid = _uidOrThrow;
    final rows = await _client
        .from('cards')
        .select('*, package:packages!package_id(name)')
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>).map((r) => CardModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// يجلب عناصر المتجر الخاصة بالمشغّل الحالي، وينشئ العناصر الافتراضية
  /// أول مرة إذا كانت القائمة فاضية.
  static Future<List<StoreItemModel>> fetchStoreItems() async {
    final uid = _uidOrThrow;
    var rows = await _client
        .from('store_items')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: true);

    if ((rows as List).isEmpty) {
      await _client.from('store_items').insert([
        {'owner_id': uid, 'category': 'starlink', 'name': 'Starlink — 3 أشهر', 'subtitle': 'سرعة عالية — تجوال دولي', 'price': 100, 'currency': 'USD'},
        {'owner_id': uid, 'category': 'starlink', 'name': 'Starlink — 6 أشهر', 'subtitle': 'الأكثر طلباً — توفير 17%', 'price': 300, 'currency': 'USD'},
        {'owner_id': uid, 'category': 'starlink', 'name': 'Starlink — سنة كاملة', 'subtitle': 'أفضل قيمة — توفير 33%', 'price': 400, 'currency': 'USD'},
        {'owner_id': uid, 'category': 'device', 'name': 'طابعة حرارية Sunmi', 'subtitle': 'طباعة كروت وايصالات — لاسلكية', 'price': 180, 'currency': 'USD'},
        {'owner_id': uid, 'category': 'device', 'name': 'جهاز MikroTik hAP', 'subtitle': 'إدارة الشبكة محلياً', 'price': 95, 'currency': 'USD'},
      ]);
      rows = await _client
          .from('store_items')
          .select()
          .eq('owner_id', uid)
          .order('created_at', ascending: true);
    }

    return (rows as List<dynamic>).map((r) => StoreItemModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// ينشئ طلب شراء حقيقي لعنصر من المتجر.
  static Future<void> createStoreOrder({required String itemId, int quantity = 1}) async {
    final uid = _uidOrThrow;
    await _client.from('store_orders').insert({
      'owner_id': uid,
      'item_id': itemId,
      'quantity': quantity,
    });
  }
}
