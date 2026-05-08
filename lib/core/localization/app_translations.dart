// ============================================================
// FILE: lib/core/localization/app_translations.dart
// PURPOSE: GetX translation messages + locale controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'en_us.dart';
import 'ar_ae.dart';
import 'ur_pk.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'ar_AE': arAe,
        'ur_PK': urPk,
      };
}

// ── Supported locales ──────────────────────────────────────
class AppLocale {
  static const Locale english = Locale('en', 'US');
  static const Locale arabic  = Locale('ar', 'AE');
  static const Locale urdu    = Locale('ur', 'PK');

  static List<Map<String, dynamic>> get supported => [
        {'locale': english, 'name': 'English',  'nativeName': 'English'},
        {'locale': arabic,  'name': 'Arabic',   'nativeName': 'العربية'},
        {'locale': urdu,    'name': 'Urdu',     'nativeName': 'اردو'},
      ];
}

// ── RTL locales ────────────────────────────────────────────
bool isRtlLocale(Locale locale) =>
    locale.languageCode == 'ar' || locale.languageCode == 'ur';
