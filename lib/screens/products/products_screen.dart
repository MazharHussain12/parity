// ============================================================
// FILE: lib/screens/products/products_screen.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/stock_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appNew_models.dart';
import '../../models/app_models.dart';
import '../dashboard/pos_screen.dart' show PosScreen;
import 'addEditProduct_screen.dart' show AddEditProductScreen;
import 'addStock_screen.dart';
import 'category_screen.dart';

// ── Navigation helpers ─────────────────────────────────────
void _goToPos() {
  if (!Get.isRegistered<PosController>()) Get.put(PosController());
  Get.to(() => const PosScreen());
}

void _goToAddStock({String? productId}) {
  if (!Get.isRegistered<StockController>()) Get.put(StockController());
  Get.to(() => AddStockScreen(preselectedProductId: productId));
}

/// If categories exist → go to Add Product.
/// If no categories → go to Categories screen so user can create one first,
/// then come back and add a product. Shows a friendly one-time tip.
void _goToAddProduct(CategoryController catCtrl) {
  if (catCtrl.categories.isEmpty) {
    // Navigate to categories screen — user must create a category first
    Get.to(() => const CategoriesScreen())?.then((_) {
      // When they come back, if they created a category now open add product
      if (catCtrl.categories.isNotEmpty) {
        Get.to(() => const AddEditProductScreen());
      }
    });

    // Friendly tip at the top so user understands why
    Get.snackbar(
      'one_more_step'.tr,
      'create_category_first_tip'.tr,
      backgroundColor:  AppColors.primary,
      colorText:        Colors.white,
      snackPosition:    SnackPosition.TOP,
      margin:           const EdgeInsets.all(16),
      duration:         const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline_rounded,
          color: Colors.white, size: 20),
    );
  } else {
    Get.to(() => const AddEditProductScreen());
  }
}

class ProductsScreen extends StatelessWidget {
  final String? filterCategoryId;
  const ProductsScreen({super.key, this.filterCategoryId});

  ProductsController get _prodCtrl {
    if (!Get.isRegistered<ProductsController>()) Get.put(ProductsController());
    return Get.find<ProductsController>();
  }

  CategoryController get _catCtrl {
    if (!Get.isRegistered<CategoryController>()) Get.put(CategoryController());
    return Get.find<CategoryController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl    = _prodCtrl;
    final catCtrl = _catCtrl;

    if (filterCategoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => ctrl.setFilterCategory(filterCategoryId!));
    }

    final tabs = ['all', 'in_stock', 'low_stock', 'out_of_stock'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ProductsHeader(ctrl: ctrl, catCtrl: catCtrl, tabs: tabs),
            const Divider(height: 1),
            Obx(() => ctrl.allProducts.isNotEmpty
                ? _StatsBar(ctrl: ctrl)
                : const SizedBox.shrink()),
            Expanded(
              child: Obx(() {
                final _ = ctrl.selectedTab.value;
                final __ = ctrl.searchQuery.value;
                final ___ = ctrl.filterCategoryId.value;
                final ____ = ctrl.allProducts.length;
                final products = ctrl.filteredProducts;

                if (ctrl.allProducts.isEmpty) {
                  return _EmptyProducts(catCtrl: catCtrl, prodCtrl: ctrl);
                }
                if (products.isEmpty) return _NoResults();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _ProductCard(product: products[i], ctrl: ctrl),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // POS button
          FloatingActionButton.small(
            heroTag:         'fab_pos',
            onPressed:       _goToPos,
            backgroundColor: AppColors.accent,
            shape:           const CircleBorder(),
            child: const Icon(Icons.point_of_sale_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          // Add product — navigates to categories first if none exist
          FloatingActionButton(
            heroTag:         'fab_add',
            onPressed:       () => _goToAddProduct(catCtrl),
            backgroundColor: AppColors.primary,
            shape:           const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────
class _ProductsHeader extends StatelessWidget {
  final ProductsController ctrl;
  final CategoryController  catCtrl;
  final List<String>        tabs;

  const _ProductsHeader({
    required this.ctrl,
    required this.catCtrl,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: GetBuilder<AppController>(
                builder: (_) =>
                    Text('products'.tr, style: AppTextStyles.h2),
              ),
            ),
            // POS shortcut
            IconButton(
              onPressed: _goToPos,
              icon: const Icon(Icons.point_of_sale_rounded,
                  color: AppColors.primary, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
            // Add stock shortcut
            IconButton(
              onPressed: () => _goToAddStock(),
              icon: const Icon(Icons.add_box_outlined,
                  color: AppColors.textPrimary, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Search bar
          GetBuilder<AppController>(
            builder: (_) => TextField(
              onChanged: ctrl.setSearch,
              decoration: InputDecoration(
                hintText:   'search_products'.tr,
                hintStyle:  AppTextStyles.label,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                filled:    true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category filter chips
          Obx(() {
            final cats = catCtrl.categories;
            if (cats.isEmpty) return const SizedBox(height: 4);
            return SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:       cats.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Obx(() => _ChipFilter(
                      label:   'all'.tr,
                      isActive: ctrl.filterCategoryId.value == 'all',
                      onTap:   () => ctrl.setFilterCategory('all'),
                      color:   AppColors.primary,
                    ));
                  }
                  final cat      = cats[i - 1];
                  final catColor = Color(cat.colorValue);
                  return Obx(() => _ChipFilter(
                    label:    cat.name,
                    emoji:    cat.emoji,
                    isActive: ctrl.filterCategoryId.value == cat.id,
                    onTap:    () => ctrl.setFilterCategory(cat.id),
                    color:    catColor,
                  ));
                },
              ),
            );
          }),

          // Stock status tabs
          const SizedBox(height: 10),
          Obx(() => Row(
            children: List.generate(tabs.length, (i) {
              final isActive = ctrl.selectedTab.value == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: i < tabs.length - 1 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => ctrl.setTab(i),
                    child: AnimatedContainer(
                      duration:  const Duration(milliseconds: 200),
                      height:    32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GetBuilder<AppController>(
                        builder: (_) => Text(
                          tabs[i].tr,
                          style: AppTextStyles.caption.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          overflow:  TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          )),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _ChipFilter extends StatelessWidget {
  final String       label;
  final String?      emoji;
  final bool         isActive;
  final VoidCallback onTap;
  final Color        color;

  const _ChipFilter({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:   const EdgeInsets.only(right: 8),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        isActive ? color : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
              color: isActive ? color : AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color:      isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Stats bar ──────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final ProductsController ctrl;
  const _StatsBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Obx(() => Row(children: [
        _StatChip(
            count: ctrl.totalProducts,
            label: 'total'.tr,
            color: AppColors.primary),
        const SizedBox(width: 8),
        _StatChip(
            count: ctrl.inStockCount,
            label: 'in_stock'.tr,
            color: AppColors.accent),
        const SizedBox(width: 8),
        _StatChip(
            count: ctrl.lowStockCount,
            label: 'low'.tr,
            color: AppColors.warning),
        const SizedBox(width: 8),
        _StatChip(
            count: ctrl.outOfStockCount,
            label: 'out'.tr,
            color: AppColors.danger),
      ])),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count; final String label; final Color color;
  const _StatChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('$count $label',
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.w700)),
  );
}

// ── Empty state ─────────────────────────────────────────────
class _EmptyProducts extends StatelessWidget {
  final CategoryController  catCtrl;
  final ProductsController  prodCtrl;
  const _EmptyProducts(
      {required this.catCtrl, required this.prodCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasCategories = catCtrl.categories.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color:        AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    hasCategories ? '🛍️' : '📂',
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GetBuilder<AppController>(
                builder: (_) => Text(
                  hasCategories
                      ? 'no_products_yet'.tr
                      : 'setup_required'.tr,
                  style:     AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              GetBuilder<AppController>(
                builder: (_) => Text(
                  hasCategories
                      ? 'add_first_product_desc'.tr
                      : 'create_category_first_desc'.tr,
                  style:     AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // Primary action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // FIX: always navigates — to categories if none exist,
                  // to add product if categories already exist
                  onPressed: () => _goToAddProduct(catCtrl),
                  icon:  const Icon(Icons.add, color: Colors.white, size: 18),
                  label: GetBuilder<AppController>(
                    builder: (_) => Text(
                      hasCategories
                          ? 'add_product'.tr
                          : 'create_category'.tr,
                      style: AppTextStyles.button,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation:       0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              // If no categories — also show a subtle hint below
              if (!hasCategories) ...[
                const SizedBox(height: 12),
                GetBuilder<AppController>(
                  builder: (_) => Text(
                    'category_required_hint'.tr,
                    style:     AppTextStyles.caption
                        .copyWith(color: AppColors.textHint),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: GetBuilder<AppController>(
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 52, color: AppColors.textHint),
          const SizedBox(height: 14),
          Text('no_results'.tr, style: AppTextStyles.h4),
        ],
      ),
    ),
  );
}

// ── Product card ───────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product            product;
  final ProductsController ctrl;
  const _ProductCard({required this.product, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusColor = product.stockStatus == StockStatus.inStock
        ? AppColors.accent
        : product.stockStatus == StockStatus.lowStock
        ? AppColors.warning
        : AppColors.danger;

    final statusLabel = product.stockStatus == StockStatus.inStock
        ? 'in_stock'.tr
        : product.stockStatus == StockStatus.lowStock
        ? 'low_stock'.tr
        : 'out_of_stock'.tr;

    return Container(
      padding:     const EdgeInsets.all(12),
      decoration:  BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Product image or category emoji fallback
        Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            color:        AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: product.imagePath != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(product.imagePath!), fit: BoxFit.cover,
            ),
          )
              : Center(
            child: Text(
              _categoryEmoji(product.categoryId),
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Product info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style:    AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                if (product.brand.isNotEmpty) ...[
                  Text(product.brand,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint)),
                  const Text(' · ',
                      style: TextStyle(color: AppColors.textHint)),
                ],
                Flexible(
                  child: Text(product.categoryName,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusLabel,
                      style: AppTextStyles.caption.copyWith(
                          color:      statusColor,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Text('${product.quantity} ${product.unit}',
                    style: AppTextStyles.caption),
              ]),
            ],
          ),
        ),

        // Price + action icons
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'AED ${product.price.toStringAsFixed(product.price < 10 ? 2 : 0)}',
              style: AppTextStyles.price.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _IconAction(
                icon:  Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                onTap: () => _goToAddStock(productId: product.id),
              ),
              const SizedBox(width: 6),
              _IconAction(
                icon:  Icons.edit_outlined,
                color: AppColors.textSecondary,
                onTap: () => Get.to(
                        () => AddEditProductScreen(editing: product)),
              ),
              const SizedBox(width: 6),
              _IconAction(
                icon:  Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: () => _confirmDelete(context),
              ),
            ]),
          ],
        ),
      ]),
    );
  }

  String _categoryEmoji(String catId) {
    if (!Get.isRegistered<CategoryController>()) return '📦';
    return Get.find<CategoryController>().findById(catId)?.emoji ?? '📦';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: GetBuilder<AppController>(
          builder: (_) =>
              Text('delete_product'.tr, style: AppTextStyles.h3),
        ),
        content: GetBuilder<AppController>(
          builder: (_) => Text(
            '${'delete_product_confirm'.tr} "${product.name}"?',
            style: AppTextStyles.bodyMd,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: GetBuilder<AppController>(
                builder: (_) => Text('cancel'.tr)),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, elevation: 0),
            child: GetBuilder<AppController>(
              builder: (_) => Text('delete'.tr,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    ),
  );
}