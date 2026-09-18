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

    if (p.startsWith('7') && p.length == 9) {
      p = '967$p';
    }

    return p;
  }

  // ============================================================
  // المخاطبة حسب جنس المريض
  // ============================================================

  static String recipient({
    required String patient,
    String gender = '',
  }) {
    final name = patient.trim();
    final g = gender.trim();

    if (g == 'ذكر' || g.toLowerCase() == 'male') {
      return 'الأخ $name';
    }

    if (g == 'أنثى' ||
        g == 'انثى' ||
        g.toLowerCase() == 'female') {
      return 'الأخت $name';
    }

    return 'المراجع $name';
  }

  // ============================================================
  // تنظيف البيانات
  // ============================================================

  static String value(
    String? text, {
    String fallback = '-',
  }) {
    final result = (text ?? '').trim();
    return result.isEmpty ? fallback : result;
  }

  // ============================================================
  // فتح WhatsApp العادي
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
  // فتح SMS
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
  // رسالة تسجيل مريض
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
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    final contact = support.trim().isEmpty
        ? ''
        : '\nللتواصل والاستفسار:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نرحب بكم في $center، ونفيدكم بأنه تم تسجيل بياناتكم بنجاح.

بيانات التسجيل:
━━━━━━━━━━━━━━━━
رقم الملف الطبي: ${value(fileNo)}
الخدمة: ${value(service)}
تاريخ التسجيل: ${value(date)}
━━━━━━━━━━━━━━━━

نشكركم على ثقتكم بنا، ونتمنى لكم دوام الصحة والعافية.

$center$contact
''';
  }

  // ============================================================
  // رسالة سند قبض
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
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    final contact = support.trim().isEmpty
        ? ''
        : '\nللتواصل والاستفسار:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نفيدكم بأنه تم تسجيل سند القبض الخاص بكم لدى $center بنجاح.

تفاصيل السند:
━━━━━━━━━━━━━━━━
رقم السند: ${value(receiptNo)}
المبلغ: ${value(amount)}
البيان: ${value(description, fallback: 'سند قبض')}
التاريخ: ${value(date)}
━━━━━━━━━━━━━━━━

تم حفظ العملية في السجل المالي.

شكرًا لتعاملكم معنا، ونتمنى لكم دوام الصحة والعافية.

$center$contact
''';
  }

  // ============================================================
  // رسالة سند صرف
  // ============================================================

  static String expenseMessage({
    required String recipientName,
    required String expenseNo,
    required String amount,
    required String category,
    required String description,
    required String center,
    required String date,
  }) {
    final person = recipientName.trim().isEmpty
        ? ''
        : '\nالمستفيد: $recipientName\n';

    return '''
السلام عليكم ورحمة الله وبركاته

إشعار سند صرف مالي

تم تسجيل سند الصرف التالي لدى $center بنجاح.
$person
تفاصيل السند:
━━━━━━━━━━━━━━━━
رقم السند: ${value(expenseNo)}
المبلغ: ${value(amount)}
الحساب: ${value(category)}
البيان: ${value(description, fallback: 'سند صرف')}
التاريخ: ${value(date)}
━━━━━━━━━━━━━━━━

$center
''';
  }

  // ============================================================
  // رسالة تسجيل جلسة
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
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نفيدكم بأنه تم تسجيل جلسة علاجية لكم لدى $center.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
اسم الباقة: ${value(packageName)}
الجلسات المستخدمة: ${value(usedSessions)}
الجلسات المتبقية: ${value(remainingSessions)}
تاريخ الجلسة: ${value(date)}
━━━━━━━━━━━━━━━━

تم تحديث رصيد الجلسات في ملفكم الطبي.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }

  // ============================================================
  // رسالة قرب انتهاء الباقة
  // ============================================================

  static String packageLowMessage({
    required String patient,
    required String center,
    required String packageName,
    required String remainingSessions,
    required String date,
    String gender = '',
  }) {
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نود تنبيهكم إلى انخفاض عدد الجلسات المتبقية في باقتكم لدى $center.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
اسم الباقة: ${value(packageName)}
الجلسات المتبقية: ${value(remainingSessions)}
التاريخ: ${value(date)}
━━━━━━━━━━━━━━━━

يمكنكم التواصل مع المركز عند الحاجة إلى تجديد الباقة.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }

  // ============================================================
  // رسالة انتهاء الباقة
  // ============================================================

  static String packageFinishedMessage({
    required String patient,
    required String center,
    required String packageName,
    required String date,
    String gender = '',
  }) {
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نفيدكم بأن جميع جلسات باقة العلاج الخاصة بكم لدى $center قد تم استخدامها.

تفاصيل الباقة:
━━━━━━━━━━━━━━━━
اسم الباقة: ${value(packageName)}
الجلسات المتبقية: 0
التاريخ: ${value(date)}
━━━━━━━━━━━━━━━━

للاستفسار عن الباقات المتاحة أو التجديد، يرجى التواصل مع المركز.

مع تمنياتنا لكم بدوام الصحة والعافية.

$center
''';
  }

  // ============================================================
  // رسالة تذكير بالموعد
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
    final person = recipient(
      patient: patient,
      gender: gender,
    );

    final doctorText = doctor.trim().isEmpty
        ? ''
        : '\nالطبيب / الأخصائي: $doctor';

    final contact = support.trim().isEmpty
        ? ''
        : '\nللتواصل والاستفسار:\n$support';

    return '''
السلام عليكم ورحمة الله وبركاته

$person،

نذكّركم بموعدكم لدى $center.

تفاصيل الموعد:
━━━━━━━━━━━━━━━━
التاريخ: ${value(date)}
الوقت: ${value(time)}
$doctorText
━━━━━━━━━━━━━━━━

نرجو الالتزام بالموعد المحدد والحضور في الوقت المناسب.

مع تمنياتنا لكم بالصحة والعافية.

$center$contact
''';
  }
}
