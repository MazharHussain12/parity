// ============================================================
// FILE: lib/screens/products/products_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/stock_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_models.dart';
import '../dashboard/pos_screen.dart' show PosScreen;
import 'addStock_screen.dart';

// ── Navigation helpers — register controllers before navigating ──
void _goToPos() {
  if (!Get.isRegistered<PosController>()) {
    Get.put(PosController());
  }
  Get.to(() => const PosScreen());
}

void _goToAddStock({String? productId}) {
  if (!Get.isRegistered<StockController>()) {
    Get.put(StockController());
  }
  Get.to(() => AddStockScreen(preselectedProductId: productId));
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductsController>();
    final tabs = [
      'all_products',
      'in_stock',
      'low_stock',
      'out_of_stock',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
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
                            color: AppColors.primary, size: 24),
                        tooltip: 'POS',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primarySurface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search_rounded,
                            color: AppColors.textPrimary, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceVariant,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded,
                            color: AppColors.textPrimary, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceVariant,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<AppController>(
                    builder: (_) => TextField(
                      onChanged: ctrl.setSearch,
                      decoration: InputDecoration(
                        hintText: 'search_products'.tr,
                        hintStyle: AppTextStyles.label,
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textHint, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Responsive tabs
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
                              duration: const Duration(milliseconds: 200),
                              height: 36,
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
                                  style: AppTextStyles.label.copyWith(
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Product list ─────────────────────────────
            Expanded(
              child: Obx(() {
                final _ = ctrl.selectedTab.value;
                final __ = ctrl.searchQuery.value;
                final ___ = ctrl.allProducts.length;
                final products = ctrl.filteredProducts;

                if (products.isEmpty) {
                  return Center(
                    child: GetBuilder<AppController>(
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text('no_products_found'.tr,
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _ProductTile(product: products[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_pos',
            onPressed: _goToPos,
            backgroundColor: AppColors.accent,
            shape: const CircleBorder(),
            child: const Icon(Icons.point_of_sale_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'fab_stock',
            onPressed: () => _goToAddStock(),
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Product tile ──────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final statusLabel = product.stockStatus == StockStatus.inStock
        ? 'in_stock'.tr
        : product.stockStatus == StockStatus.lowStock
        ? 'low_stock'.tr
        : 'out_of_stock'.tr;

    final statusStyle = product.stockStatus == StockStatus.inStock
        ? AppTextStyles.inStock
        : product.stockStatus == StockStatus.lowStock
        ? AppTextStyles.lowStock
        : AppTextStyles.outStock;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(product.imageEmoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                GetBuilder<AppController>(
                  builder: (_) =>
                      Text(product.category.tr, style: AppTextStyles.label),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(statusLabel, style: statusStyle),
              Text('${product.quantity} ${'pcs'.tr}',
                  style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(
                'AED ${product.price.toStringAsFixed(product.price < 10 ? 2 : 0)}',
                style: AppTextStyles.price,
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Per-row quick add-stock button
          GestureDetector(
            onTap: () => _goToAddStock(productId: product.id),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}