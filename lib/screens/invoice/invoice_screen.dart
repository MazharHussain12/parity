// ============================================================
// FILE: lib/screens/invoice/invoice_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/invoice_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appNew_models.dart';
import '../../models/app_models.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  // Self-register controller if not already present
  InvoiceController get _ctrl {
    if (!Get.isRegistered<InvoiceController>()) {
      Get.put(InvoiceController());
    }
    return Get.find<InvoiceController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    final fmt  = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary, size: 24),
        ),
        title: Text('invoice'.tr, style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textPrimary, size: 22),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Obx(() {
        // Reactive — rebuilds if setInvoice() is called
        final inv = ctrl.currentInvoice;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Column(
            children: [
              // ── Invoice card ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // ── Header row ─────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.invoiceNo,
                                    style: AppTextStyles.invoiceTitle),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(inv.date),
                                  style: AppTextStyles.label,
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: inv.status),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // ── Bill to / from ─────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _BillBlock(
                              title:   'bill_to'.tr,
                              name:    inv.billToName,
                              address: inv.billToAddress,
                              extra:   inv.billToPhone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BillBlock(
                              title:   'bill_from'.tr,
                              name:    inv.billFromName,
                              address: inv.billFromAddress,
                              extra:   '${'trn_label'.tr} ${inv.billFromTrn}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // ── Items table header ─────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(children: [
                        Expanded(
                            child: Text('items'.tr,
                                style: AppTextStyles.label)),
                        SizedBox(
                          width: 36,
                          child: Text('qty'.tr,
                              style: AppTextStyles.label,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('price'.tr,
                              style: AppTextStyles.label,
                              textAlign: TextAlign.right),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('total'.tr,
                              style: AppTextStyles.label,
                              textAlign: TextAlign.right),
                        ),
                      ]),
                    ),
                    const Divider(height: 1),

                    // ── Line items ─────────────────────
                    ...inv.items.map(
                          (item) => _InvoiceLineItem(item: item, fmt: fmt),
                    ),
                    const Divider(height: 1),

                    // ── Totals ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _TotalRow(
                          label: 'subtotal'.tr,
                          value: 'AED ${fmt.format(inv.subtotal)}',
                        ),
                        const SizedBox(height: 8),
                        _TotalRow(
                          label: 'discount'.tr,
                          value: '- AED ${fmt.format(inv.discount)}',
                          valueStyle: AppTextStyles.invoiceValue
                              .copyWith(color: AppColors.danger),
                        ),
                        const SizedBox(height: 8),
                        _TotalRow(
                          label: 'vat'.tr,
                          value: 'AED ${fmt.format(inv.vatAmount)}',
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('total'.tr, style: AppTextStyles.h3),
                            Text('AED ${fmt.format(inv.total)}',
                                style: AppTextStyles.invoiceTotal),
                          ],
                        ),
                      ]),
                    ),
                    const Divider(height: 1),

                    // ── Payment info ───────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('payment_info'.tr, style: AppTextStyles.h4),
                          const SizedBox(height: 10),
                          _PaymentRow(
                            label: 'payment_method'.tr,
                            value: inv.paymentMethod,
                          ),
                          const SizedBox(height: 6),
                          _PaymentRow(
                            label: 'paid_amount'.tr,
                            value: 'AED ${fmt.format(inv.total)}',
                          ),
                          const SizedBox(height: 6),
                          _PaymentRow(
                            label: 'change'.tr,
                            value: 'AED 0.00',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Action buttons ───────────────────────
              SizedBox(
                width:  double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation:       0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon:  const Icon(Icons.download_rounded,
                      color: Colors.white, size: 20),
                  label: Text('download_pdf'.tr,
                      style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon:  const Icon(Icons.chat_rounded,
                        color: AppColors.whatsapp, size: 18),
                    label: Text('share_whatsapp'.tr,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon:  const Icon(Icons.email_outlined,
                        color: AppColors.primary, size: 18),
                    label: Text('send_email'.tr,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }
}

// ── Status badge ───────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final InvoiceStatus status;          // ← uses InvoiceStatus from app_models
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid     = status == InvoiceStatus.paid;
    final isCancelled = status == InvoiceStatus.cancelled;

    final bg    = isPaid ? AppColors.accentLight
        : isCancelled   ? AppColors.dangerLight
        : AppColors.warningLight;
    final color = isPaid ? AppColors.accent
        : isCancelled   ? AppColors.danger
        : AppColors.warning;
    final label = isPaid ? 'paid'.tr
        : isCancelled   ? 'cancelled'.tr
        : 'pending'.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color, width: 1),
      ),
      child: Text(label,
          style: AppTextStyles.bodySm.copyWith(
              color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Bill block ─────────────────────────────────────────────
class _BillBlock extends StatelessWidget {
  final String title, name, address, extra;
  const _BillBlock({
    required this.title,
    required this.name,
    required this.address,
    required this.extra,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.label),
      const SizedBox(height: 4),
      Text(name,
          style: AppTextStyles.invoiceValue
              .copyWith(fontWeight: FontWeight.w600)),
      if (address.isNotEmpty)
        Text(address, style: AppTextStyles.invoiceLabel),
      if (extra.isNotEmpty)
        Text(extra,
            style:    AppTextStyles.invoiceLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
    ],
  );
}

// ── Line item row ──────────────────────────────────────────
class _InvoiceLineItem extends StatelessWidget {
  final InvoiceItem  item;    // ← uses InvoiceItem from app_models
  final NumberFormat fmt;
  const _InvoiceLineItem({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Expanded(
          child: Text(item.name, style: AppTextStyles.invoiceValue)),
      SizedBox(
        width: 36,
        child: Text('${item.qty}',
            style:     AppTextStyles.invoiceValue,
            textAlign: TextAlign.center),
      ),
      SizedBox(
        width: 70,
        child: Text(fmt.format(item.price),
            style:     AppTextStyles.invoiceValue,
            textAlign: TextAlign.right),
      ),
      SizedBox(
        width: 70,
        child: Text(fmt.format(item.total),
            style:     AppTextStyles.invoiceValue,
            textAlign: TextAlign.right),
      ),
    ]),
  );
}

// ── Total row ──────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final String     label, value;
  final TextStyle? valueStyle;
  const _TotalRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.invoiceLabel),
      Text(value, style: valueStyle ?? AppTextStyles.invoiceValue),
    ],
  );
}

// ── Payment row ────────────────────────────────────────────
class _PaymentRow extends StatelessWidget {
  final String label, value;
  const _PaymentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(
      width: 130,
      child: Text(label, style: AppTextStyles.invoiceLabel),
    ),
    Expanded(
      child: Text(value, style: AppTextStyles.invoiceValue),
    ),
  ]);
}