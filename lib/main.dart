import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة اللغة العربية والتواريخ.
  await initializeDateFormatting('ar');

  // إعداد محرك SQLite للويب.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // تهيئة قاعدة البيانات قبل تشغيل التطبيق.
  await DatabaseService.instance.initialize();

  runApp(const WaseemMedicalApp());
}
