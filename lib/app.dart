import 'package:flutter/material.dart';

import 'services/settings_service.dart';
import 'screens/splash_screen.dart';

class WaseemMedicalApp extends StatefulWidget {
  const WaseemMedicalApp({super.key});

  @override
  State<WaseemMedicalApp> createState() => _WaseemMedicalAppState();
}

class _WaseemMedicalAppState extends State<WaseemMedicalApp> {
  bool dark = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedDarkMode = await SettingsService.instance.isDarkMode();

    if (!mounted) return;

    setState(() {
      dark = savedDarkMode;
    });
  }

  Future<void> toggleTheme() async {
    final newValue = !dark;

    await SettingsService.instance.setDarkMode(newValue);

    if (!mounted) return;

    setState(() {
      dark = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B7891);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'وسيم ميديكال',

      // الاتجاه الافتراضي للتطبيق باللغة العربية.
      locale: const Locale('ar'),

      themeMode: dark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),

        fontFamily: 'Arial',

        scaffoldBackgroundColor: const Color(0xFFF4F8FB),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: Color(0xFFD7E2EA),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: Color(0xFFD7E2EA),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: seed,
              width: 1.5,
            ),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),

        fontFamily: 'Arial',
      ),

      home: SplashScreen(
        onThemeChanged: toggleTheme,
      ),
    );
  }
}
