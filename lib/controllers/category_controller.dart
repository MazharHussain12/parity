// ============================================================
// FILE: lib/controllers/category_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/appNew_models.dart';
import '../models/app_models.dart';

class CategoryController extends GetxController {
  final RxList<ProductCategory> categories = <ProductCategory>[].obs;
  final RxString selectedCategoryId        = 'all'.obs;

  // Preset emoji + color options for picker
  static const List<String> emojiOptions = [
    '📦','🛍️','🍎','🥛','🧴','💊','👕','👟','📱','💻',
    '🪑','🛠️','🧹','🍕','☕','🍰','🌿','🚗','📚','🎮',
    '💄','💍','🏋️','🎵','🖨️','📷','🔌','🧊','🥩','🫙',
  ];

  static const List<int> colorOptions = [
    0xFF2563EB, // blue
    0xFF16A34A, // green
    0xFFDC2626, // red
    0xFFD97706, // amber
    0xFF7C3AED, // purple
    0xFFDB2777, // pink
    0xFF0891B2, // cyan
    0xFF059669, // emerald
    0xFFEA580C, // orange
    0xFF4F46E5, // indigo
    0xFF0F766E, // teal
    0xFF9333EA, // violet
  ];

  // ── CRUD ───────────────────────────────────────────────
  void addCategory({
    required String name,
    required String emoji,
    required int colorValue,
  }) {
    if (name.trim().isEmpty) return;
    // Check duplicate name
    if (categories.any(
            (c) => c.name.toLowerCase() == name.trim().toLowerCase())) {
      Get.snackbar(
        'duplicate'.tr, 'category_exists'.tr,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    categories.add(ProductCategory(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      name:       name.trim(),
      emoji:      emoji,
      colorValue: colorValue,
      createdAt:  DateTime.now(),
    ));

    Get.snackbar(
      'success'.tr, 'category_added'.tr,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  void updateCategory({
    required String id,
    required String name,
    required String emoji,
    required int colorValue,
  }) {
    final idx = categories.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    categories[idx] = categories[idx].copyWith(
      name:       name.trim(),
      emoji:      emoji,
      colorValue: colorValue,
    );
    categories.refresh();
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    if (selectedCategoryId.value == id) {
      selectedCategoryId.value = 'all';
    }
  }

  void selectCategory(String id) => selectedCategoryId.value = id;

  ProductCategory? findById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}