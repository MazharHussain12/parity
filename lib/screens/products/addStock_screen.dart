// ============================================================
// FILE: lib/screens/stock/add_stock_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/stock_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_models.dart';

class AddStockScreen extends StatelessWidget {
  final String? preselectedProductId;
  const AddStockScreen({super.key, this.preselectedProductId});

  // ── Self-register controller if not already registered ──
  StockController get ctrl {
    if (!Get.isRegistered<StockController>()) {
      Get.put(StockController());
    }
    return Get.find<StockController>();
  }

  @override
  Widget build(BuildContext context) {
    final c         = ctrl; // triggers registration once
    final prodCtrl  = Get.find<ProductsController>();

    // Pre-select product if navigated from product row
    if (preselectedProductId != null &&
        c.selectedProductId.value != preselectedProductId) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => c.selectProduct(preselectedProductId!));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
              // ── Select Product ────────────────────────
              _SectionLabel(label: 'select_product'.tr),
              const SizedBox(height: 10),
              Obx(() {
                final _ = prodCtrl.allProducts.length;
                return _ProductPickerGrid(
                  products: prodCtrl.allProducts.toList(),
                  selectedId: c.selectedProductId.value,
                  onSelect: c.selectProduct,
                );
              }),
              const SizedBox(height: 24),

              // ── Selected product card ─────────────────
              Obx(() {
                final product = c.selectedProduct;
                if (product == null) return const SizedBox.shrink();
                return _SelectedProductCard(product: product);
              }),
              Obx(() =>
              c.selectedProduct != null
                  ? const SizedBox(height: 24)
                  : const SizedBox.shrink()),

              // ── Qty to add ────────────────────────────
              Obx(() {
                if (c.selectedProduct == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'quantity_to_add'.tr),
                    const SizedBox(height: 10),
                    _QtySelector(
                      value: c.addQty.value,
                      onChanged: c.setQty,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'note_optional'.tr),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: c.note.value,
                      onChanged: c.setNote,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Received from supplier',
                        hintStyle: AppTextStyles.label,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
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
                    c.selectedProduct != null && c.addQty.value > 0;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    canSubmit && !c.isLoading.value
                        ? c.confirmAddStock
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : GetBuilder<AppController>(
                      builder: (_) => Text(
                        'confirm_add_stock'.tr,
                      //  style: AppTextStyles.button,
                      ),
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

// ── Widgets ───────────────────────────────────────────────

class _ProductPickerGrid extends StatelessWidget {
  final List<Product> products;
  final String selectedId;
  final void Function(String) onSelect;
  const _ProductPickerGrid({
    required this.products,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p          = products[i];
        final isSelected = p.id == selectedId;
        return GestureDetector(
          onTap: () => onSelect(p.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primarySurface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.imageEmoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  p.name,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _StockBadge(status: p.stockStatus, qty: p.quantity),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StockBadge extends StatelessWidget {
  final StockStatus status;
  final int qty;
  const _StockBadge({required this.status, required this.qty});

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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$qty ${'pcs'.tr}',
          style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}

class _SelectedProductCard extends StatelessWidget {
  final Product product;
  const _SelectedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(product.imageEmoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
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
              GetBuilder<AppController>(
                builder: (_) =>
                    Text('current_stock'.tr, style: AppTextStyles.caption),
              ),
              Text(
                '${product.quantity} ${'pcs'.tr}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _QtySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyBtn(
          icon: Icons.remove,
          onTap: () => onChanged(value - 1),
          enabled: value > 0,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              key: ValueKey(value),
              initialValue: value == 0 ? '' : '$value',
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.h2.copyWith(fontSize: 28),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTextStyles.h2
                    .copyWith(fontSize: 28, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
            ),
          ),
        ),
        _QtyBtn(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
          enabled: true,
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _QtyBtn(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary));
  }
}