// ============================================================
// FILE: lib/screens/stock/add_stock_screen.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/stock_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appNew_models.dart';
import '../../models/app_models.dart';

class AddStockScreen extends StatelessWidget {
  final String? preselectedProductId;
  const AddStockScreen({super.key, this.preselectedProductId});

  StockController get _ctrl {
    if (!Get.isRegistered<StockController>()) Get.put(StockController());
    return Get.find<StockController>();
  }

  // Resolve category emoji for a product
  static String _emoji(String categoryId) {
    if (!Get.isRegistered<CategoryController>()) return '📦';
    return Get.find<CategoryController>().findById(categoryId)?.emoji ?? '📦';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl     = _ctrl;
    final prodCtrl = Get.isRegistered<ProductsController>()
        ? Get.find<ProductsController>()
        : Get.put(ProductsController());

    if (preselectedProductId != null &&
        ctrl.selectedProductId.value != preselectedProductId) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => ctrl.selectProduct(preselectedProductId!));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: Get.back,
        ),
        title: GetBuilder<AppController>(
          builder: (_) => Text('add_stock'.tr, style: AppTextStyles.h3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Select product ────────────────────────
              _SectionLabel(label: 'select_product'.tr),
              const SizedBox(height: 10),
              Obx(() {
                final _ = prodCtrl.allProducts.length;
                return _ProductPickerGrid(
                  products:   prodCtrl.allProducts.toList(),
                  selectedId: ctrl.selectedProductId.value,
                  onSelect:   ctrl.selectProduct,
                );
              }),
              const SizedBox(height: 24),

              // ── Selected product card ─────────────────
              Obx(() {
                final product = ctrl.selectedProduct;
                if (product == null) return const SizedBox.shrink();
                return _SelectedProductCard(product: product);
              }),
              Obx(() => ctrl.selectedProduct != null
                  ? const SizedBox(height: 24)
                  : const SizedBox.shrink()),

              // ── Qty + note ────────────────────────────
              Obx(() {
                if (ctrl.selectedProduct == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'quantity_to_add'.tr),
                    const SizedBox(height: 10),
                    _QtySelector(
                      value:     ctrl.addQty.value,
                      onChanged: ctrl.setQty,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'note_optional'.tr),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: ctrl.note.value,
                      onChanged:    ctrl.setNote,
                      maxLines:     2,
                      style:        AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        hintText:  'stock_note_hint'.tr,
                        hintStyle: AppTextStyles.label,
                        filled:    true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:   BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5)),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // ── Confirm button ────────────────────────
              Obx(() {
                final canSubmit =
                    ctrl.selectedProduct != null && ctrl.addQty.value > 0;
                return SizedBox(
                  width:  double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit && !ctrl.isLoading.value
                        ? ctrl.confirmAddStock : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:        AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor:        Colors.white,
                      elevation:              0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: ctrl.isLoading.value
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : GetBuilder<AppController>(
                      builder: (_) => Text('confirm_add_stock'.tr,
                          style: AppTextStyles.button),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Product picker grid ────────────────────────────────────
class _ProductPickerGrid extends StatelessWidget {
  final List<Product>          products;
  final String                 selectedId;
  final void Function(String)  onSelect;

  const _ProductPickerGrid({
    required this.products,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: GetBuilder<AppController>(
          builder: (_) => Text('no_products_found'.tr,
              style: AppTextStyles.label),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics:    const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   3,
        childAspectRatio: 0.88,
        crossAxisSpacing: 10,
        mainAxisSpacing:  10,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p          = products[i];
        final isSelected = p.id == selectedId;
        return GestureDetector(
          onTap: () => onSelect(p.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:  const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primarySurface : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Product image or category emoji
                _ProductThumb(product: p, size: 44),
                const SizedBox(height: 6),
                Text(p.name,
                    style: AppTextStyles.label.copyWith(
                      color:      isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines:  2,
                    overflow:  TextOverflow.ellipsis),
                const SizedBox(height: 4),
                _StockBadge(status: p.stockStatus, qty: p.quantity, unit: p.unit),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Product thumbnail (image or emoji fallback) ────────────
class _ProductThumb extends StatelessWidget {
  final Product product;
  final double  size;
  const _ProductThumb({required this.product, required this.size});

  @override
  Widget build(BuildContext context) {
    if (product.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(product.imagePath!),
          width: size, height: size, fit: BoxFit.cover,
        ),
      );
    }
    return Text(
      AddStockScreen._emoji(product.categoryId),
      style: TextStyle(fontSize: size * 0.6),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final StockStatus status;
  final int         qty;
  final String      unit;
  const _StockBadge({
    required this.status, required this.qty, required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == StockStatus.inStock
        ? AppColors.accent
        : status == StockStatus.lowStock
        ? AppColors.warning
        : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$qty $unit',
          style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}

// ── Selected product card ──────────────────────────────────
class _SelectedProductCard extends StatelessWidget {
  final Product product;
  const _SelectedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color:        AppColors.surface,
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
              AddStockScreen._emoji(product.categoryId),
              style: const TextStyle(fontSize: 26),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: AppTextStyles.h4),
              const SizedBox(height: 2),
              Text(product.categoryName,
                  style: AppTextStyles.label),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GetBuilder<AppController>(
              builder: (_) => Text('current_stock'.tr,
                  style: AppTextStyles.caption),
            ),
            Text('${product.quantity} ${product.unit}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
          ],
        ),
      ]),
    );
  }
}

// ── Qty selector ───────────────────────────────────────────
class _QtySelector extends StatelessWidget {
  final int value; final void Function(int) onChanged;
  const _QtySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    _QtyBtn(icon: Icons.remove, onTap: () => onChanged(value - 1),
        enabled: value > 0),
    Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          key:             ValueKey(value),
          initialValue:    value == 0 ? '' : '$value',
          textAlign:       TextAlign.center,
          keyboardType:    TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.h2.copyWith(fontSize: 28),
          decoration: InputDecoration(
            hintText:  '0',
            hintStyle: AppTextStyles.h2.copyWith(
                fontSize: 28, color: AppColors.textHint),
            filled:    true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide.none),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
        ),
      ),
    ),
    _QtyBtn(icon: Icons.add, onTap: () => onChanged(value + 1),
        enabled: true),
  ]);
}

class _QtyBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool enabled;
  const _QtyBtn({required this.icon, required this.onTap, required this.enabled});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color:        enabled ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary));
}