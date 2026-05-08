// ============================================================
// FILE: lib/controllers/app_controller.dart
// PURPOSE: Root controller for locale + nav state
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/localization/app_translations.dart';

class AppController extends GetxController {
  // ── Bottom nav ────────────────────────────────────────────
  final RxInt currentNavIndex = 0.obs;
  void setNavIndex(int i) => currentNavIndex.value = i;

  // ── Language ──────────────────────────────────────────────
  final Rx<Locale> currentLocale = AppLocale.english.obs;

  void changeLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  bool get isRtl => isRtlLocale(currentLocale.value);
}
