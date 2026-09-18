import 'package:url_launcher/url_launcher.dart';

class MessagingService {
  // ============================================================
  // توحيد رقم الهاتف اليمني
  // ============================================================

  static String normalizeYemen(String phone) {
    var p = phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');

    if (p.startsWith('+')) {
      p = p.substring(1);
    }

    if (p.startsWith('00')) {
      p = p.substring(2);
    }

    // مثال: 777123456 -> 967777123456
    if (p.startsWith('7') && p.length == 9) {
      p = '967$p';
    }

    return p;
  }

  // ============================================================
  // فتح WhatsApp العادي وتجهيز الرسالة
  // ============================================================

  static Future<bool> whatsapp(
    String phone,
    String message,
  ) async {
    final p = normalizeYemen(phone);

    if (p.isEmpty) {
      return false;
    }

    final uri = Uri.parse(
      'https://wa.me/$p?text=${Uri.encodeComponent(message)}',
    );

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // فتح SMS وتجهيز الرسالة
  // ============================================================

  static Future<bool> sms(
    String phone,
    String message,
  ) async {
    final p = normalizeYemen(phone);

    if (p.isEmpty) {
      return false;
    }

    final uri = Uri(
      scheme: 'sms',
      path: p,
      queryParameters: {
        'body': message,
      },
    );

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // تحديد صيغة المخاطبة حسب الجنس
  //
  // ذكر  -> الأخ
  // أنثى -> الأخت
  // غير محدد -> العميل / المراجع
  // ============================================================

  static String greeting({
    required String patient,
    String? gender,
  }) {
    final name = patient.trim();

    final g = (gender ?? '').trim().toLowerCase();

    if (g == 'ذكر' ||
        g == 'ذكر ' ||
        g == 'male' ||
        g == 'm') {
      return 'الأخ $name';
    }

    if (g == 'أنثى' ||
        g == 'انثى' ||
        g == 'female' ||
        g == 'f') {
      return 'الأخت $name';
    }

    return 'المراجع $name';
  }

  // ============================================================
  // تنظيف النص
  // ============================================================

  static String clean(String? value, {String fallback = '-'}) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  // ============================================================
  // إشعار تسجيل مريض جديد
  // ============================================================

  static String registrationMessage({
    required String patient,
    required String fileNo,
    required String center,
    required String service,
    required String date,
    required String support,
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    final supportText = support.trim().isEmpty
        ? ''
        : '\nللاستفسار والتواصل:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نرحب بكم في $center، ونفيدكم بأنه تم تسجيل بياناتكم في النظام بنجاح.

بيانات التسجيل:
━━━━━━━━━━━━━━━━
رقم الملف الطبي: ${clean(fileNo)}
الخدمة: ${clean(service)}
تاريخ التسجيل: ${clean(date)}
━━━━━━━━━━━━━━━━

نشكركم على ثقتكم بنا، ونسأل الله لكم دوام الصحة والعافية.

$center
$supportText
''';
  }

  // ============================================================
  // إشعار سند قبض
  // ============================================================

  static String receiptMessage({
    required String patient,
    required String receiptNo,
    required String amount,
    required String description,
    required String center,
    required String date,
    String support = '',
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    final supportText = support.trim().isEmpty
        ? ''
        : '\nللاستفسار والتواصل:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نفيدكم بأنه تم تسجيل سند القبض الخاص بكم لدى $center بنجاح.

تفاصيل السند:
━━━━━━━━━━━━━━━━
رقم السند: ${clean(receiptNo)}
المبلغ: ${clean(amount)}
البيان: ${clean(description, fallback: 'سند قبض')}
التاريخ: ${clean(date)}
━━━━━━━━━━━━━━━━

تم حفظ العملية في السجل المالي للمركز.

شكرًا لتعاملكم معنا، ونتمنى لكم دوام الصحة والعافية.

$center
$supportText
''';
  }

  // ============================================================
  // إشعار سند صرف
  // ============================================================

  static String expenseMessage({
    required String recipient,
    required String expenseNo,
    required String amount,
    required String category,
    required String description,
    required String center,
    required String date,
  }) {
    final recipientText = recipient.trim().isEmpty
        ? ''
        : '\nالمستفيد: $recipient\n';

    return '''
السلام عليكم ورحمة الله وبركاته

إشعار سند صرف مالي

تم تسجيل سند الصرف التالي لدى $center بنجاح.
$recipientText
تفاصيل السند:
━━━━━━━━━━━━━━━━
رقم السند: ${clean(expenseNo)}
المبلغ: ${clean(amount)}
الحساب: ${clean(category)}
البيان: ${clean(description, fallback: 'سند صرف')}
التاريخ: ${clean(date)}
━━━━━━━━━━━━━━━━

$center
''';
  }

  // ============================================================
  // إشعار تسجيل جلسة
  // ============================================================

  static String sessionUsageMessage({
    required String patient,
    required String center,
    required String usedSessions,
    required String remainingSessions,
    required String packageName,
    required String date,
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نفيدكم بأنه تم تسجيل جلسة علاجية لكم لدى $center.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
الباقة: ${clean(packageName)}
الجلسات المستخدمة: ${clean(usedSessions)}
الجلسات المتبقية: ${clean(remainingSessions)}
تاريخ الجلسة: ${clean(date)}
━━━━━━━━━━━━━━━━

تم تحديث رصيد الجلسات في ملفكم الطبي.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }

  // ============================================================
  // إشعار قرب انتهاء الباقة
  // ============================================================

  static String packageLowMessage({
    required String patient,
    required String center,
    required String packageName,
    required String remainingSessions,
    required String date,
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نود تنبيهكم إلى انخفاض عدد الجلسات المتبقية في باقتكم لدى $center.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
اسم الباقة: ${clean(packageName)}
الجلسات المتبقية: ${clean(remainingSessions)}
التاريخ: ${clean(date)}
━━━━━━━━━━━━━━━━

يمكنكم التواصل مع المركز عند الحاجة إلى تجديد الباقة أو الاستفسار عن الخدمات.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }

  // ============================================================
  // تذكير بالموعد
  // ============================================================

  static String appointmentMessage({
    required String patient,
    required String center,
    required String date,
    required String time,
    required String doctor,
    required String support,
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    final doctorText = doctor.trim().isEmpty
        ? ''
        : '\nالطبيب / الأخصائي: $doctor';

    final supportText = support.trim().isEmpty
        ? ''
        : '\nللاستفسار والتواصل:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نذكّركم بموعدكم لدى $center.

تفاصيل الموعد:
━━━━━━━━━━━━━━━━
التاريخ: ${clean(date)}
الوقت: ${clean(time)}
$doctorText
━━━━━━━━━━━━━━━━

نرجو الالتزام بالموعد المحدد، والحضور في الوقت المناسب.

مع تمنياتنا لكم بالصحة والعافية.

$center
$supportText
''';
  }

  // ============================================================
  // إشعار انتهاء الباقة بالكامل
  // ============================================================

  static String packageFinishedMessage({
    required String patient,
    required String center,
    required String packageName,
    required String date,
    String gender = '',
  }) {
    final recipient = greeting(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$recipient،

نفيدكم بأن جميع جلسات باقة العلاج الخاصة بكم لدى $center قد تم استخدامها.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
اسم الباقة: ${clean(packageName)}
الجلسات المتبقية: 0
التاريخ: ${clean(date)}
━━━━━━━━━━━━━━━━

يمكنكم التواصل مع المركز للاستفسار عن الباقات المتاحة أو تجديد الباقة.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }
}
