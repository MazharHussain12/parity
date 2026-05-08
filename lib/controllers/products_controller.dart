// ============================================================
// FILE: lib/controllers/products_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/appNew_models.dart';
import '../models/app_models.dart';
import 'category_controller.dart';

class ProductsController extends GetxController {
  final RxList<Product> allProducts      = <Product>[].obs;
  final RxInt           selectedTab      = 0.obs;
  final RxString        searchQuery      = ''.obs;
  final RxString        filterCategoryId = 'all'.obs;

  final RxString formImagePath = ''.obs;
  final RxBool   formIsLoading = false.obs;

  final _picker = ImagePicker();

  // ── Filtered list ──────────────────────────────────────
  List<Product> get filteredProducts {
    final q   = searchQuery.value.toLowerCase();
    final cat = filterCategoryId.value;
    return allProducts.where((p) {
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q)         ||
          p.brand.toLowerCase().contains(q)        ||
          p.barcode.toLowerCase().contains(q)      ||
          p.categoryName.toLowerCase().contains(q);
      final matchCat = cat == 'all' || p.categoryId == cat;
      final matchTab = selectedTab.value == 0 ||
          (selectedTab.value == 1 && p.stockStatus == StockStatus.inStock)    ||
          (selectedTab.value == 2 && p.stockStatus == StockStatus.lowStock)   ||
          (selectedTab.value == 3 && p.stockStatus == StockStatus.outOfStock);
      return matchSearch && matchCat && matchTab;
    }).toList();
  }

  List<Product> productsByCategory(String categoryId) =>
      allProducts.where((p) => p.categoryId == categoryId).toList();

  // ── CRUD ───────────────────────────────────────────────
  void addProduct({
    required String name,
    required String brand,
    required String categoryId,
    required double price,
    required double costPrice,
    required int    quantity,
    required int    lowStockThreshold,
    required String barcode,
    required String unit,
    required String description,
    String?         imagePath,
  }) {
    if (name.trim().isEmpty) return;

    // FIX: use ?. and fallback empty string — category lookup can return null
    final cat    = _safeFindCategory(categoryId);
    final catName = cat?.name ?? '';

    final newQty = quantity.clamp(0, 999999);
    final status = _computeStatus(newQty, lowStockThreshold);

    allProducts.add(Product(
      id:                DateTime.now().millisecondsSinceEpoch.toString(),
      name:              name.trim(),
      brand:             brand.trim(),
      categoryId:        categoryId,
      categoryName:      catName,
      price:             price,
      costPrice:         costPrice,
      quantity:          newQty,
      lowStockThreshold: lowStockThreshold,
      stockStatus:       status,
      imagePath:         imagePath,
      barcode:           barcode.trim(),
      unit:              unit,
      description:       description.trim(),
      createdAt:         DateTime.now(),
    ));
    allProducts.refresh();
  }

  void updateProduct(
      String id, {
        String?  name,
        String?  brand,
        String?  categoryId,
        double?  price,
        double?  costPrice,
        int?     quantity,
        int?     lowStockThreshold,
        String?  barcode,
        String?  unit,
        String?  description,
        String?  imagePath,
      }) {
    final idx = allProducts.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final old      = allProducts[idx];
    final newCatId = categoryId ?? old.categoryId;

    // FIX: safe null check on category lookup
    final cat     = _safeFindCategory(newCatId);
    final catName = cat?.name ?? old.categoryName;

    final newQty    = quantity ?? old.quantity;
    final newThresh = lowStockThreshold ?? old.lowStockThreshold;

    allProducts[idx] = old.copyWith(
      name:              name,
      brand:             brand,
      categoryId:        newCatId,
      categoryName:      catName,
      price:             price,
      costPrice:         costPrice,
      quantity:          newQty,
      lowStockThreshold: newThresh,
      stockStatus:       _computeStatus(newQty, newThresh),
      imagePath:         imagePath,
      barcode:           barcode,
      unit:              unit,
      description:       description,
    );
    allProducts.refresh();
  }

  void deleteProduct(String id) =>
      allProducts.removeWhere((p) => p.id == id);

  // ── Stock ──────────────────────────────────────────────
  void addStock(String productId, int qty) {
    final idx = allProducts.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    final old    = allProducts[idx];
    final newQty = old.quantity + qty;
    allProducts[idx] = old.copyWith(
      quantity:    newQty,
      stockStatus: _computeStatus(newQty, old.lowStockThreshold),
    );
    allProducts.refresh();
  }

  void deductStock(String productId, int qty) {
    final idx = allProducts.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    final old    = allProducts[idx];
    final newQty = (old.quantity - qty).clamp(0, 999999);
    allProducts[idx] = old.copyWith(
      quantity:    newQty,
      stockStatus: _computeStatus(newQty, old.lowStockThreshold),
    );
    allProducts.refresh();
  }

  // ── Image picking ──────────────────────────────────────
  Future<String?> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source:       source,
        imageQuality: 80,
        maxWidth:     800,
      );
      if (picked != null) {
        formImagePath.value = picked.path;
        return picked.path;
      }
    } catch (_) {}
    return null;
  }

  void clearFormImage() => formImagePath.value = '';

  // ── Filters ────────────────────────────────────────────
  void setTab(int i)              => selectedTab.value = i;
  void setSearch(String q)        => searchQuery.value = q;
  void setFilterCategory(String id) => filterCategoryId.value = id;

  // ── Stats ──────────────────────────────────────────────
  int get totalProducts   => allProducts.length;
  int get inStockCount    =>
      allProducts.where((p) => p.stockStatus == StockStatus.inStock).length;
  int get lowStockCount   =>
      allProducts.where((p) => p.stockStatus == StockStatus.lowStock).length;
  int get outOfStockCount =>
      allProducts.where((p) => p.stockStatus == StockStatus.outOfStock).length;

  // ── Helpers ────────────────────────────────────────────
  StockStatus _computeStatus(int qty, int threshold) {
    if (qty == 0)          return StockStatus.outOfStock;
    if (qty <= threshold)  return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  /// Safe category lookup — returns null if CategoryController not registered
  /// or category id not found. Callers must use ?. or provide fallback.
  ProductCategory? _safeFindCategory(String categoryId) {
    if (!Get.isRegistered<CategoryController>()) return null;
    return Get.find<CategoryController>().findById(categoryId);
  }
}