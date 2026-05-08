// ============================================================
// FILE: lib/controllers/stock_controller.dart
// PURPOSE: Manages stock quantity additions for products
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/app_models.dart';
import 'products_controller.dart';

class StockController extends GetxController {
  // ── Form state ─────────────────────────────────────────
  final RxString selectedProductId = ''.obs;
  final RxInt addQty              = 0.obs;
  final RxString note             = ''.obs;
  final RxBool isLoading          = false.obs;

  // ── Stock movement log ─────────────────────────────────
  final RxList<StockMovement> movements = <StockMovement>[].obs;

  // Shortcut to currently selected product
  Product? get selectedProduct {
    final pc = Get.find<ProductsController>();
    if (selectedProductId.value.isEmpty) return null;
    try {
      return pc.allProducts
          .firstWhere((p) => p.id == selectedProductId.value);
    } catch (_) {
      return null;
    }
  }

  void selectProduct(String id) {
    selectedProductId.value = id;
    addQty.value = 0;
    note.value = '';
  }

  void setQty(int qty) => addQty.value = qty < 0 ? 0 : qty;
  void setNote(String n) => note.value = n;

  Future<void> confirmAddStock() async {
    if (selectedProductId.value.isEmpty || addQty.value <= 0) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400)); // simulate API

    final pc = Get.find<ProductsController>();
    pc.addStock(selectedProductId.value, addQty.value);

    movements.insert(
      0,
      StockMovement(
        productId:   selectedProductId.value,
        productName: selectedProduct?.name ?? '',
        qty:         addQty.value,
        note:        note.value,
        date:        DateTime.now(),
      ),
    );

    isLoading.value = false;

    Get.back();
    Get.snackbar(
      'stock_added'.tr,
      '${addQty.value} ${'units_added'.tr} ${selectedProduct?.name ?? ''}',
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );

    // Reset
    addQty.value = 0;
    note.value   = '';
  }
}

// ── Model ──────────────────────────────────────────────────
class StockMovement {
  final String productId;
  final String productName;
  final int    qty;
  final String note;
  final DateTime date;

  const StockMovement({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.note,
    required this.date,
  });
}