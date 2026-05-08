// ============================================================
// FILE: lib/main.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ABC Trading Co.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // ── Localisation ──────────────────────────────────
      translations: AppTranslations(),
      locale: AppLocale.english,
      fallbackLocale: AppLocale.english,

      // ── RTL support ───────────────────────────────────
      builder: (context, child) {
        // Watch locale via GetX to handle RTL dynamically
        return Directionality(
          textDirection: _isRtlLocale(Get.locale ?? AppLocale.english)
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      // ── Home ─────────────────────────────────────────
      home: const HomeShell(),
    );
  }

  bool _isRtlLocale(Locale locale) =>
      locale.languageCode == 'ar' || locale.languageCode == 'ur';
}
