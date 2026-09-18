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
  // اسم المركز
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

  // ============================================================
  // رقم التواصل
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

  // ============================================================
  // مسح الإعدادات
  // ============================================================

  Future<void> clearSettings() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove('dark_mode');
    await preferences.remove('center_name');
    await preferences.remove('support_phone');
  }
}
