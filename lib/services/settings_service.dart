import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  // ============================================================
  // الوضع الليلي
  // ============================================================

  Future<bool> isDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('dark_mode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', value);
  }

  // ============================================================
  // بيانات المركز الأساسية
  // ============================================================

  Future<String> centerName() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_name') ??
        'المركز الأول للعلاج الطبيعي والتأهيل - دمت';
  }

  Future<void> setCenterName(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_name',
      value.trim(),
    );
  }

  Future<String> commercialName() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('commercial_name') ?? '';
  }

  Future<void> setCommercialName(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'commercial_name',
      value.trim(),
    );
  }

  Future<String> centerDescription() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_description') ?? '';
  }

  Future<void> setCenterDescription(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_description',
      value.trim(),
    );
  }

  // ============================================================
  // العنوان
  // ============================================================

  Future<String> address() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_address') ?? '';
  }

  Future<void> setAddress(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_address',
      value.trim(),
    );
  }

  Future<String> city() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_city') ?? '';
  }

  Future<void> setCity(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_city',
      value.trim(),
    );
  }

  // ============================================================
  // أرقام التواصل
  // ============================================================

  Future<String> supportPhone() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('support_phone') ??
        '774486588';
  }

  Future<void> setSupportPhone(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'support_phone',
      value.trim(),
    );
  }

  Future<String> whatsappPhone() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('whatsapp_phone') ?? '';
  }

  Future<void> setWhatsappPhone(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'whatsapp_phone',
      value.trim(),
    );
  }

  Future<String> email() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_email') ?? '';
  }

  Future<void> setEmail(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_email',
      value.trim(),
    );
  }

  Future<String> website() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_website') ?? '';
  }

  Future<void> setWebsite(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_website',
      value.trim(),
    );
  }

  // ============================================================
  // بيانات إضافية
  // ============================================================

  Future<String> taxNumber() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('tax_number') ?? '';
  }

  Future<void> setTaxNumber(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'tax_number',
      value.trim(),
    );
  }

  // ============================================================
  // بيانات الفواتير والطباعة
  // ============================================================

  Future<String> invoiceName() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('invoice_name') ?? '';
  }

  Future<void> setInvoiceName(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'invoice_name',
      value.trim(),
    );
  }

  Future<String> invoiceAddress() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('invoice_address') ?? '';
  }

  Future<void> setInvoiceAddress(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'invoice_address',
      value.trim(),
    );
  }

  Future<String> invoicePhone() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('invoice_phone') ?? '';
  }

  Future<void> setInvoicePhone(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'invoice_phone',
      value.trim(),
    );
  }

  Future<String> invoiceFooter() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('invoice_footer') ??
        'شكرًا لثقتكم بنا';
  }

  Future<void> setInvoiceFooter(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'invoice_footer',
      value.trim(),
    );
  }

  Future<bool> showLogoOnInvoice() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool('show_logo_on_invoice') ?? true;
  }

  Future<void> setShowLogoOnInvoice(bool value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(
      'show_logo_on_invoice',
      value,
    );
  }

  // ============================================================
  // شعار المركز
  // ============================================================

  Future<String> logoBase64() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString('center_logo') ?? '';
  }

  Future<void> setLogoBase64(String value) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'center_logo',
      value,
    );
  }

  Future<void> removeLogo() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove('center_logo');
  }

  // ============================================================
  // مسح الإعدادات
  // ============================================================

  Future<void> clearSettings() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove('dark_mode');

    await preferences.remove('center_name');
    await preferences.remove('commercial_name');
    await preferences.remove('center_description');

    await preferences.remove('center_address');
    await preferences.remove('center_city');

    await preferences.remove('support_phone');
    await preferences.remove('whatsapp_phone');
    await preferences.remove('center_email');
    await preferences.remove('center_website');

    await preferences.remove('tax_number');

    await preferences.remove('invoice_name');
    await preferences.remove('invoice_address');
    await preferences.remove('invoice_phone');
    await preferences.remove('invoice_footer');
    await preferences.remove('show_logo_on_invoice');

    await preferences.remove('center_logo');
  }
}
