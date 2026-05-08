// ============================================================
// FILE: lib/screens/pos/pos_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_models.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  // ── Self-register controller if not already registered ──
  PosController get ctrl {
    if (!Get.isRegistered<PosController>()) {
      Get.put(PosController());
    }
    return Get.find<PosController>();
  }

  @override
  Widget build(BuildContext context) {
    final c = ctrl; // triggers registration once

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
          builder: (_) => Text('pos'.tr, style: AppTextStyles.h3),
        ),
        actions: [
          Obx(() => c.cart.isNotEmpty
              ? TextButton.icon(
            onPressed: () => _showClearConfirm(context, c),
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger, size: 18),
            label: GetBuilder<AppController>(
              builder: (_) => Text('clear'.tr,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.danger)),
            ),
          )
              : const SizedBox.shrink()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          c.showDropdown.value = false;
        },
        child: Column(
          children: [
            _PosSearchBar(ctrl: c),
            Expanded(
              child: Obx(() {
                if (c.cart.isEmpty) return _EmptyCart();
                return _CartList(ctrl: c);
              }),
            ),
            Obx(() => c.cart.isNotEmpty
                ? _CustomerSection(ctrl: c)
                : const SizedBox.shrink()),
            Obx(() => c.cart.isNotEmpty
                ? _OrderSummary(ctrl: c)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  void _showClearConfirm(BuildContext context, PosController c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: GetBuilder<AppController>(
          builder: (_) => Text('clear_cart'.tr, style: AppTextStyles.h3),
        ),
        content: GetBuilder<AppController>(
          builder: (_) =>
              Text('clear_cart_confirm'.tr, style: AppTextStyles.bodyLg),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: GetBuilder<AppController>(
                builder: (_) => Text('cancel'.tr)),
          ),
          ElevatedButton(
            onPressed: () {
              c.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, elevation: 0),
            child: GetBuilder<AppController>(
              builder: (_) => Text('clear'.tr,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────
class _PosSearchBar extends StatelessWidget {
  final PosController ctrl;
  const _PosSearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          GetBuilder<AppController>(
            builder: (_) => TextField(
              onChanged: (v) {
                ctrl.searchQuery.value  = v;
                ctrl.showDropdown.value = v.isNotEmpty;
              },
              decoration: InputDecoration(
                hintText: 'search_add_product'.tr,
                hintStyle: AppTextStyles.label,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Obx(() {
            final _ = ctrl.searchQuery.value;
            final results = ctrl.searchResults;
            if (!ctrl.showDropdown.value || results.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final p = results[i];
                  return ListTile(
                    dense: true,
                    leading: Text(p.imageEmoji,
                        style: const TextStyle(fontSize: 22)),
                    title: Text(p.name, style: AppTextStyles.h4),
                    subtitle: Text(
                        'AED ${p.price.toStringAsFixed(p.price < 10 ? 2 : 0)} · ${p.quantity} ${'pcs'.tr}',
                        style: AppTextStyles.label),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                      const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                    onTap: () => ctrl.addToCart(p),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Empty cart ─────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<AppController>(
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('cart_empty'.tr, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('search_to_add'.tr,
                style: AppTextStyles.label,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Cart list ──────────────────────────────────────────────
class _CartList extends StatelessWidget {
  final PosController ctrl;
  const _CartList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: ctrl.cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CartItemCard(
        item: ctrl.cart[i],
        index: i,
        ctrl: ctrl,
      ),
    ));
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final PosController ctrl;
  const _CartItemCard(
      {required this.item, required this.index, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(item.product.imageEmoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: AppTextStyles.h4),
                    GetBuilder<AppController>(
                      builder: (_) => Text(item.product.category.tr,
                          style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ctrl.removeFromCart(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.danger, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<AppController>(
                      builder: (_) =>
                          Text('qty'.tr, style: AppTextStyles.caption),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => _InlineQtyEditor(
                      value: item.qty.value,
                      onChanged: (v) => ctrl.updateQty(index, v),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<AppController>(
                      builder: (_) => Text('unit_price'.tr,
                          style: AppTextStyles.caption),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => _InlinePriceEditor(
                      value: item.price.value,
                      onChanged: (v) => ctrl.updatePrice(index, v),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GetBuilder<AppController>(
                    builder: (_) =>
                        Text('total'.tr, style: AppTextStyles.caption),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    'AED ${item.total.toStringAsFixed(2)}',
                    style: AppTextStyles.price
                        .copyWith(color: AppColors.primary),
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineQtyEditor extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _InlineQtyEditor({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniBtn(icon: Icons.remove, onTap: () => onChanged(value - 1)),
        Expanded(
          child: TextFormField(
            key: ValueKey(value),
            initialValue: '$value',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.h4,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
            ),
            onChanged: (v) => onChanged(int.tryParse(v) ?? 1),
          ),
        ),
        _MiniBtn(icon: Icons.add, onTap: () => onChanged(value + 1)),
      ],
    );
  }
}

class _InlinePriceEditor extends StatelessWidget {
  final double value;
  final void Function(double) onChanged;
  const _InlinePriceEditor({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(value.toStringAsFixed(2)),
      initialValue: value.toStringAsFixed(2),
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      style: AppTextStyles.h4,
      decoration: InputDecoration(
        prefixText: 'AED ',
        prefixStyle: AppTextStyles.caption,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        isDense: true,
      ),
      onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 16),
      ),
    );
  }
}

// ── Customer + note ────────────────────────────────────────
class _CustomerSection extends StatelessWidget {
  final PosController ctrl;
  const _CustomerSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          GetBuilder<AppController>(
            builder: (_) => Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (v) => ctrl.customerName.value = v,
                    decoration: InputDecoration(
                      hintText: 'customer_name_optional'.tr,
                      hintStyle: AppTextStyles.label,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.textHint, size: 20),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    onChanged: (v) => ctrl.invoiceNote.value = v,
                    decoration: InputDecoration(
                      hintText: 'note_optional'.tr,
                      hintStyle: AppTextStyles.label,
                      prefixIcon: const Icon(Icons.notes_rounded,
                          color: AppColors.textHint, size: 20),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Order summary ──────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final PosController ctrl;
  const _OrderSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          Obx(() => _SummaryRow(
            label: 'subtotal'.tr,
            value: 'AED ${ctrl.subtotal.toStringAsFixed(2)}',
          )),
          const SizedBox(height: 6),
          Obx(() => _SummaryRow(
            label: 'vat_5'.tr,
            value: 'AED ${ctrl.vatAmount.toStringAsFixed(2)}',
            labelColor: AppColors.textSecondary,
          )),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Obx(() => _SummaryRow(
            label: 'grand_total'.tr,
            value: 'AED ${ctrl.grandTotal.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primary,
          )),
          const SizedBox(height: 16),
          Obx(() => ctrl.isGenerating.value
              ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
              : _InvoiceActions(ctrl: ctrl)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? labelColor;
  final Color? valueColor;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isBold
                ? AppTextStyles.h4.copyWith(color: labelColor)
                : AppTextStyles.label.copyWith(color: labelColor)),
        Text(value,
            style: isBold
                ? AppTextStyles.h3.copyWith(color: valueColor)
                : AppTextStyles.h4.copyWith(color: valueColor)),
      ],
    );
  }
}

// ── Invoice action buttons ─────────────────────────────────
class _InvoiceActions extends StatelessWidget {
  final PosController ctrl;
  const _InvoiceActions({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.share_rounded,
          label: 'whatsapp'.tr,
          color: const Color(0xFF25D366),
          onTap: () => _showLanguagePicker(context, 'whatsapp'),
        ),
        const SizedBox(width: 8),
        _ActionBtn(
          icon: Icons.email_outlined,
          label: 'email'.tr,
          color: const Color(0xFFEA4335),
          onTap: () => _showLanguagePicker(context, 'email'),
        ),
        const SizedBox(width: 8),
        _ActionBtn(
          icon: Icons.download_rounded,
          label: 'save'.tr,
          color: AppColors.textSecondary,
          onTap: () => _showLanguagePicker(context, 'download'),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _showLanguagePicker(context, 'any'),
            icon: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 18),
            label: GetBuilder<AppController>(
              builder: (_) => Text('generate_invoice'.tr,
                  style: const TextStyle(color: Colors.white)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(BuildContext context, String method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(
        onSelected: (locale) => ctrl.generateAndShareInvoice(
            locale: locale, shareMethod: method),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Language picker sheet ──────────────────────────────────
class _LanguagePickerSheet extends StatelessWidget {
  final void Function(String locale) onSelected;
  const _LanguagePickerSheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final langs = [
      {'locale': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'locale': 'ur', 'label': 'اردو',    'flag': '🇵🇰'},
      {'locale': 'ar', 'label': 'العربية', 'flag': '🇦🇪'},
    ];
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<AppController>(
            builder: (_) =>
                Text('invoice_language'.tr, style: AppTextStyles.h3),
          ),
          const SizedBox(height: 6),
          GetBuilder<AppController>(
            builder: (_) => Text('select_invoice_lang'.tr,
                style: AppTextStyles.label, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          Row(
            children: langs.map((l) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onSelected(l['locale']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(l['flag']!,
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(l['label']!,
                              style: AppTextStyles.h4
                                  .copyWith(color: AppColors.primary),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}