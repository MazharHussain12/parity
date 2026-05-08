// ============================================================
// FILE: lib/core/theme/app_text_styles.dart
// PURPOSE: Centralised typography — update once, change everywhere
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Font family helpers ────────────────────────────────────
  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ── Display / Hero ─────────────────────────────────────────
  static TextStyle get heroAmount => _base(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle get heroProfitAmount => heroAmount.copyWith(
        color: AppColors.accent,
      );

  // ── Headings ──────────────────────────────────────────────
  static TextStyle get h1 => _base(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get h3 => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get h4 => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // ── Body ──────────────────────────────────────────────────
  static TextStyle get bodyLg => _base(fontSize: 15, height: 1.5);
  static TextStyle get bodyMd => _base(fontSize: 14, height: 1.5);
  static TextStyle get bodySm => _base(fontSize: 13, height: 1.4);
  static TextStyle get bodyXs => _base(fontSize: 11, height: 1.4);

  // ── Label / Caption ───────────────────────────────────────
  static TextStyle get label => _base(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => _base(
        fontSize: 11,
        color: AppColors.textHint,
      );

  // ── Price / Amount ────────────────────────────────────────
  static TextStyle get price => _base(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get priceLg => _base(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // ── Status tags ───────────────────────────────────────────
  static TextStyle get inStock =>
      _base(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inStockText);
  static TextStyle get lowStock =>
      _base(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lowStockText);
  static TextStyle get outStock =>
      _base(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outStockText);

  // ── On-primary (white text on coloured bg) ────────────────
  static TextStyle get onPrimary => _base(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get onPrimaryBold => onPrimary.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      );

  // ── Invoice specific ──────────────────────────────────────
  static TextStyle get invoiceTitle => _base(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get invoiceLabel => _base(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get invoiceValue => _base(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get invoiceTotal => _base(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // ── Navigation ────────────────────────────────────────────
  static TextStyle get navLabel => _base(fontSize: 10, fontWeight: FontWeight.w500);
}
