// ============================================================
// FILE: lib/core/theme/app_colors.dart
// PURPOSE: Central color palette — change here to retheme entire app
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand ──────────────────────────────────────────
  static const Color primary         = Color(0xFF1A56DB);   // Main blue
  static const Color primaryLight    = Color(0xFF3B82F6);   // Lighter blue
  static const Color primaryDark     = Color(0xFF1E40AF);   // Deeper blue
  static const Color primarySurface  = Color(0xFFEFF6FF);   // Very light blue bg

  // ── Accent / Action ───────────────────────────────────────
  static const Color accent          = Color(0xFF10B981);   // Green (profit, paid)
  static const Color accentLight     = Color(0xFFD1FAE5);   // Light green bg
  static const Color warning         = Color(0xFFF59E0B);   // Amber (low stock)
  static const Color warningLight    = Color(0xFFFEF3C7);   // Light amber bg
  static const Color danger          = Color(0xFFEF4444);   // Red (out of stock, discount)
  static const Color dangerLight     = Color(0xFFFEE2E2);   // Light red bg

  // ── Neutral / Surface ─────────────────────────────────────
  static const Color background      = Color(0xFFF8FAFC);   // App background
  static const Color surface         = Color(0xFFFFFFFF);   // Cards, sheets
  static const Color surfaceVariant  = Color(0xFFF1F5F9);   // Input fills, dividers
  static const Color border          = Color(0xFFE2E8F0);   // Light border

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFF0F172A);   // Headings
  static const Color textSecondary   = Color(0xFF64748B);   // Labels, subtitles
  static const Color textHint        = Color(0xFFCBD5E1);   // Placeholders
  static const Color textOnPrimary   = Color(0xFFFFFFFF);   // Text on blue bg

  // ── Chart line ────────────────────────────────────────────
  static const Color chartLine       = Color(0xFF1A56DB);
  static const Color chartDot        = Color(0xFF1A56DB);
  static const Color chartFill       = Color(0x261A56DB);   // 15% opacity

  // ── Status badges ─────────────────────────────────────────
  static const Color inStockText     = Color(0xFF059669);
  static const Color lowStockText    = Color(0xFFD97706);
  static const Color outStockText    = Color(0xFFDC2626);

  // ── Bottom nav ────────────────────────────────────────────
  static const Color navActive       = Color(0xFF1A56DB);
  static const Color navInactive     = Color(0xFF94A3B8);
  static const Color navFab          = Color(0xFF1A56DB);

  // ── WhatsApp green (share button) ─────────────────────────
  static const Color whatsapp        = Color(0xFF25D366);
}
