import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// عميل خفيف لبروتوكول RouterOS API الخاص بأجهزة MikroTik (منفذ 8728 بدون TLS).
/// لا توجد حزمة Dart رسمية لهذا البروتوكول، فهذا تطبيق يدوي لتنسيق "الجمل"
/// الثنائي (binary sentence) المستخدم في RouterOS API.
///
/// بيانات الاتصال (العنوان/اليوزر/الباسورد) تُمرَّر من الخارج دائماً — هذا
/// الملف لا يقرأها ولا يخزّنها؛ شاشة الإعدادات هي من تحتفظ بها محلياً عبر
/// SharedPreferences فقط (لا ترفع أبداً لقاعدة بيانات Supabase).
class RouterOsException implements Exception {
  final String message;
  RouterOsException(this.message);
  @override
  String toString() => 'RouterOsException: $message';
}

class RouterOsService {
  final String host;
  final int port;
  final String username;
  final String password;
  final Duration timeout;

  Socket? _socket;
  final _buffer = <int>[];
  StreamSubscription<List<int>>? _sub;

  RouterOsService({
    required this.host,
    required this.username,
    required this.password,
    this.port = 8728,
    this.timeout = const Duration(seconds: 8),
  });

  /// يفتح اتصال TCP مع الراوتر ويسجّل الدخول. يرمي RouterOsException لو
  /// فشلت المصادقة أو تعذّر الوصول للعنوان.
  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
    } on SocketException catch (e) {
      throw RouterOsException('تعذّر الوصول إلى الراوتر على $host:$port — ${e.osError?.message ?? e.message}');
    }

    _sub = _socket!.listen(
      (data) => _buffer.addAll(data),
      onError: (_) {},
      cancelOnError: false,
    );

    await _login();
  }

  Future<void> _login() async {
    // RouterOS >= 6.43 يستخدم /login بخطوة واحدة (plain password)
    final reply = await _talk(['/login', '=name=$username', '=password=$password']);
    final tag = reply.isNotEmpty ? reply.first.first : '';
    if (tag == '!trap' || tag == '!fatal') {
      throw RouterOsException('فشل تسجيل الدخول — تحقق من اسم المستخدم وكلمة المرور');
    }
  }

  /// يرسل أمر RouterOS API ويعيد كل الجمل (sentences) المستلمة حتى !done.
  Future<List<List<String>>> _talk(List<String> words) async {
    if (_socket == null) throw RouterOsException('الاتصال غير مفتوح');
    _writeSentence(words);

    final sentences = <List<String>>[];
    final deadline = DateTime.now().add(timeout);

    while (true) {
      final sentence = await _readSentence(deadline);
      if (sentence == null) break;
      sentences.add(sentence);
      if (sentence.isNotEmpty && sentence.first == '!done') break;
    }
    return sentences;
  }

  void _writeSentence(List<String> words) {
    final out = <int>[];
    for (final w in words) {
      out.addAll(_encodeWord(w));
    }
    out.add(0x00); // نهاية الجملة
    _socket!.add(out);
  }

  List<int> _encodeWord(String word) {
    final bytes = utf8.encode(word);
    final len = _encodeLength(bytes.length);
    return [...len, ...bytes];
  }

  List<int> _encodeLength(int length) {
    if (length < 0x80) {
      return [length];
    } else if (length < 0x4000) {
      final l = length | 0x8000;
      return [(l >> 8) & 0xFF, l & 0xFF];
    } else if (length < 0x200000) {
      final l = length | 0xC00000;
      return [(l >> 16) & 0xFF, (l >> 8) & 0xFF, l & 0xFF];
    } else if (length < 0x10000000) {
      final l = length | 0xE0000000;
      return [(l >> 24) & 0xFF, (l >> 16) & 0xFF, (l >> 8) & 0xFF, l & 0xFF];
    } else {
      return [0xF0, (length >> 24) & 0xFF, (length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF];
    }
  }

  Future<List<String>?> _readSentence(DateTime deadline) async {
    final words = <String>[];
    while (true) {
      final len = await _readLength(deadline);
      if (len == null) return words.isEmpty ? null : words;
      if (len == 0) return words;
      final bytes = await _readBytes(len, deadline);
      words.add(utf8.decode(bytes, allowMalformed: true));
    }
  }

  Future<int?> _readByte(DateTime deadline) async {
    while (_buffer.isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        throw RouterOsException('انتهت مهلة الاتصال بالراوتر — تحقق من الشبكة والعنوان');
      }
      await Future.delayed(const Duration(milliseconds: 20));
    }
    return _buffer.removeAt(0);
  }

  Future<int?> _readLength(DateTime deadline) async {
    final c = await _readByte(deadline);
    if (c == null) return null;
    if ((c & 0x80) == 0x00) {
      return c;
    } else if ((c & 0xC0) == 0x80) {
      final c2 = await _readByte(deadline) ?? 0;
      return ((c & 0x3F) << 8) + c2;
    } else if ((c & 0xE0) == 0xC0) {
      final c2 = await _readByte(deadline) ?? 0;
      final c3 = await _readByte(deadline) ?? 0;
      return ((c & 0x1F) << 16) + (c2 << 8) + c3;
    } else if ((c & 0xF0) == 0xE0) {
      final c2 = await _readByte(deadline) ?? 0;
      final c3 = await _readByte(deadline) ?? 0;
      final c4 = await _readByte(deadline) ?? 0;
      return ((c & 0x0F) << 24) + (c2 << 16) + (c3 << 8) + c4;
    } else {
      final c2 = await _readByte(deadline) ?? 0;
      final c3 = await _readByte(deadline) ?? 0;
      final c4 = await _readByte(deadline) ?? 0;
      final c5 = await _readByte(deadline) ?? 0;
      return (c2 << 24) + (c3 << 16) + (c4 << 8) + c5;
    }
  }

  Future<List<int>> _readBytes(int n, DateTime deadline) async {
    final out = <int>[];
    for (var i = 0; i < n; i++) {
      out.add(await _readByte(deadline) ?? 0);
    }
    return out;
  }

  /// يحوّل جمل الرد (كل جملة فيها كلمات =key=value) لقائمة خرائط سهلة الاستخدام.
  List<Map<String, String>> _parseReplyRows(List<List<String>> sentences) {
    final rows = <Map<String, String>>[];
    Map<String, String>? current;
    for (final sentence in sentences) {
      for (final word in sentence) {
        if (word == '!re') {
          if (current != null) rows.add(current);
          current = {};
        } else if (word.startsWith('=')) {
          final rest = word.substring(1);
          final eq = rest.indexOf('=');
          if (eq != -1) {
            current ??= {};
            current[rest.substring(0, eq)] = rest.substring(eq + 1);
          }
        }
      }
    }
    if (current != null && current.isNotEmpty) rows.add(current);
    return rows;
  }

  /// قائمة المستخدمين المتصلين فعلياً بالهوتسبوت الآن (شاشة المراقبة الحقيقية).
  Future<List<Map<String, String>>> activeHotspotUsers() async {
    final reply = await _talk(['/ip/hotspot/active/print']);
    return _parseReplyRows(reply);
  }

  /// كل مستخدمي الهوتسبوت المعرّفين على الراوتر (وليس فقط المتصلين الآن).
  Future<List<Map<String, String>>> hotspotUsers() async {
    final reply = await _talk(['/ip/hotspot/user/print']);
    return _parseReplyRows(reply);
  }

  /// يفصل مستخدماً متصلاً بالهوتسبوت فوراً (باستخدام .id من activeHotspotUsers).
  Future<void> disconnectActiveUser(String activeId) async {
    await _talk(['/ip/hotspot/active/remove', '=.id=$activeId']);
  }

  /// يضيف مستخدم هوتسبوت جديد على الراوتر مطابقاً لكرت تم توليده في التطبيق،
  /// مع ربطه اختيارياً بجهاز واحد (قفل الكرت على أول جهاز يستخدمه).
  Future<void> addHotspotUser({
    required String name,
    required String password,
    String? profile,
    String? limitUptime,
    String? macAddress,
  }) async {
    final words = [
      '/ip/hotspot/user/add',
      '=name=$name',
      '=password=$password',
      if (profile != null) '=profile=$profile',
      if (limitUptime != null) '=limit-uptime=$limitUptime',
      if (macAddress != null) '=mac-address=$macAddress',
    ];
    await _talk(words);
  }

  /// معلومات هوية الراوتر الأساسية — يُستخدم للتحقق السريع من صحة بيانات الدخول.
  Future<Map<String, String>> identity() async {
    final reply = await _talk(['/system/identity/print']);
    final rows = _parseReplyRows(reply);
    return rows.isNotEmpty ? rows.first : {};
  }

  Future<void> close() async {
    await _sub?.cancel();
    await _socket?.close();
    _socket = null;
  }
}
