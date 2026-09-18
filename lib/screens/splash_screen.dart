import 'dart:async';

import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../widgets/app_shell.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const SplashScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  String _centerName = 'المركز الأول للعلاج الطبيعي والتأهيل - دمت';
  String _supportPhone = '774486588';

  @override
  void initState() {
    super.initState();

    _loadSettings();

    _timer = Timer(
      const Duration(milliseconds: 1400),
      _openApp,
    );
  }

  Future<void> _loadSettings() async {
    final centerName = await SettingsService.instance.centerName();
    final supportPhone = await SettingsService.instance.supportPhone();

    if (!mounted) return;

    setState(() {
      _centerName = centerName;
      _supportPhone = supportPhone;
    });
  }

  void _openApp() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppShell(
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF7FA),
              Color(0xFFF9FCFD),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B7891),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 62,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'وسيم ميديكال',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063E4D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'WASEEM MEDICAL PRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'نظام طبي وإداري ومحاسبي متكامل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _centerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'الدعم: $_supportPhone',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 35),

                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
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
}
