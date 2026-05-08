// ============================================================
// FILE: lib/controllers/pos_controller.dart
// PURPOSE: POS cart, invoice generation, sharing
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';
import 'products_controller.dart';

class CartItem {
  final Product product;
  final RxInt  qty;
  final RxDouble price;

  CartItem({required this.product, int qty = 1})
      : qty   = qty.obs,
        price = product.price.obs;

  double get total => qty.value * price.value;
}

class PosController extends GetxController {
  // ── Search ─────────────────────────────────────────────
  final RxString searchQuery    = ''.obs;
  final RxBool   showDropdown   = false.obs;

  // ── Cart ───────────────────────────────────────────────
  final RxList<CartItem> cart   = <CartItem>[].obs;

  // ── Invoice meta ───────────────────────────────────────
  final RxString customerName   = ''.obs;
  final RxString invoiceNote    = ''.obs;
  final RxBool   isGenerating   = false.obs;

  // Invoice counter (would come from DB in production)
  int _invoiceCounter = 1000;

  String get nextInvoiceNo => 'INV-${(_invoiceCounter + 1).toString().padLeft(5, '0')}';

  // ── Filtered product search results ───────────────────
  List<Product> get searchResults {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return [];
    final pc = Get.find<ProductsController>();
    return pc.allProducts
        .where((p) =>
    p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q))
        .toList();
  }

  // ── Cart totals ────────────────────────────────────────
  double get subtotal =>
      cart.fold(0.0, (sum, item) => sum + item.total);

  double get vatAmount => subtotal * 0.05; // 5% UAE VAT

  double get grandTotal => subtotal + vatAmount;

  int get totalItems => cart.fold(0, (sum, item) => sum + item.qty.value);

  // ── Cart operations ────────────────────────────────────
  void addToCart(Product p) {
    searchQuery.value  = '';
    showDropdown.value = false;

    final existing = cart.firstWhereOrNull((c) => c.product.id == p.id);
    if (existing != null) {
      existing.qty.value++;
    } else {
      cart.add(CartItem(product: p));
    }
    cart.refresh();
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
  }

  void updateQty(int index, int qty) {
    if (qty <= 0) {
      removeFromCart(index);
      return;
    }
    cart[index].qty.value = qty;
    cart.refresh();
  }

  void updatePrice(int index, double price) {
    if (price < 0) return;
    cart[index].price.value = price;
    cart.refresh();
  }

  void clearCart() {
    cart.clear();
    customerName.value = '';
    invoiceNote.value  = '';
    searchQuery.value  = '';
  }

  // ── Invoice generation ─────────────────────────────────
  Future<void> generateAndShareInvoice({
    required String locale,      // 'en', 'ur', 'ar'
    required String shareMethod, // 'download', 'whatsapp', 'email', 'any'
  }) async {
    if (cart.isEmpty) return;
    isGenerating.value = true;

    try {
      _invoiceCounter++;
      final invoiceNo = 'INV-${_invoiceCounter.toString().padLeft(5, '0')}';
      final now       = DateTime.now();
      final dateStr   = DateFormat('dd MMM yyyy, hh:mm a').format(now);
      final isRtl     = locale == 'ar' || locale == 'ur';

      // ── Build PDF ─────────────────────────────────────
      final pdf  = pw.Document();
      final font = pw.Font.helvetica();
      final bold = pw.Font.helveticaBold();

      // Translated strings
      final t = _InvoiceTranslations(locale);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PARTIX',
                          style: pw.TextStyle(
                              font: bold, fontSize: 28, color: PdfColor.fromHex('2563EB'))),
                      pw.Text(t.invoiceTitle,
                          style: pw.TextStyle(font: font, fontSize: 14,
                              color: PdfColor.fromHex('6B7280'))),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(invoiceNo,
                          style: pw.TextStyle(font: bold, fontSize: 16)),
                      pw.Text(dateStr,
                          style: pw.TextStyle(font: font, fontSize: 11,
                              color: PdfColor.fromHex('6B7280'))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: PdfColor.fromHex('E5E7EB'), thickness: 1),
              pw.SizedBox(height: 8),

              // Customer
              if (customerName.value.isNotEmpty) ...[
                pw.Text('${t.billTo}: ${customerName.value}',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.SizedBox(height: 12),
              ],

              // Table header
              pw.Container(
                color: PdfColor.fromHex('EFF6FF'),
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4,
                        child: pw.Text(t.product,
                            style: pw.TextStyle(font: bold, fontSize: 11))),
                    pw.Expanded(flex: 1,
                        child: pw.Text(t.qty,
                            style: pw.TextStyle(font: bold, fontSize: 11),
                            textAlign: pw.TextAlign.center)),
                    pw.Expanded(flex: 2,
                        child: pw.Text(t.unitPrice,
                            style: pw.TextStyle(font: bold, fontSize: 11),
                            textAlign: pw.TextAlign.right)),
                    pw.Expanded(flex: 2,
                        child: pw.Text(t.total,
                            style: pw.TextStyle(font: bold, fontSize: 11),
                            textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Table rows
              ...cart.asMap().entries.map((e) {
                final idx  = e.key;
                final item = e.value;
                final bg   = idx.isEven
                    ? PdfColors.white
                    : PdfColor.fromHex('F9FAFB');
                return pw.Container(
                  color: bg,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.product.name,
                                  style: pw.TextStyle(font: bold, fontSize: 11)),
                              pw.Text(item.product.category,
                                  style: pw.TextStyle(font: font, fontSize: 9,
                                      color: PdfColor.fromHex('9CA3AF'))),
                            ],
                          )),
                      pw.Expanded(flex: 1,
                          child: pw.Text('${item.qty.value}',
                              style: pw.TextStyle(font: font, fontSize: 11),
                              textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2,
                          child: pw.Text(
                              'AED ${item.price.value.toStringAsFixed(2)}',
                              style: pw.TextStyle(font: font, fontSize: 11),
                              textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2,
                          child: pw.Text(
                              'AED ${item.total.toStringAsFixed(2)}',
                              style: pw.TextStyle(font: bold, fontSize: 11),
                              textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
              }),

              pw.Divider(color: PdfColor.fromHex('E5E7EB'), thickness: 1),
              pw.SizedBox(height: 8),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(width: 200,
                      child: pw.Column(
                        children: [
                          _pdfTotalRow(t.subtotal,
                              'AED ${subtotal.toStringAsFixed(2)}', font, bold),
                          _pdfTotalRow('${t.vat} (5%)',
                              'AED ${vatAmount.toStringAsFixed(2)}', font, bold),
                          pw.Divider(
                              color: PdfColor.fromHex('2563EB'), thickness: 1.5),
                          _pdfTotalRow(t.grandTotal,
                              'AED ${grandTotal.toStringAsFixed(2)}', bold, bold,
                              highlight: true),
                        ],
                      )),
                ],
              ),

              // Note
              if (invoiceNote.value.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('FFF7ED'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text('${t.note}: ${invoiceNote.value}',
                      style: pw.TextStyle(font: font, fontSize: 11)),
                ),
              ],

              pw.Spacer(),
              pw.Divider(color: PdfColor.fromHex('E5E7EB')),
              pw.Center(
                child: pw.Text(t.thankYou,
                    style: pw.TextStyle(font: font, fontSize: 11,
                        color: PdfColor.fromHex('6B7280'))),
              ),
            ],
          ),
        ),
      );

      // ── Save PDF ────────────────────────────────────────
      final Uint8List bytes = await pdf.save();
      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/$invoiceNo.pdf');
      await file.writeAsBytes(bytes);

      // ── Deduct stock ────────────────────────────────────
      final pc = Get.find<ProductsController>();
      for (final item in cart) {
        pc.deductStock(item.product.id, item.qty.value);
      }

      // ── Share ───────────────────────────────────────────
      final xFile = XFile(file.path, mimeType: 'application/pdf');

      switch (shareMethod) {
        case 'whatsapp':
          await Share.shareXFiles(
            [xFile],
            text: '${t.invoiceTitle} $invoiceNo\n${t.grandTotal}: AED ${grandTotal.toStringAsFixed(2)}',
            subject: '${t.invoiceTitle} $invoiceNo',
          );
          break;
        case 'email':
          await Share.shareXFiles(
            [xFile],
            subject: '${t.invoiceTitle} $invoiceNo',
            text: '${t.invoiceTitle} $invoiceNo\n${t.grandTotal}: AED ${grandTotal.toStringAsFixed(2)}',
          );
          break;
        case 'download':
        // On mobile, saving to documents
          final docsDir = await getApplicationDocumentsDirectory();
          final savedFile = File('${docsDir.path}/$invoiceNo.pdf');
          await savedFile.writeAsBytes(bytes);
          Get.snackbar(
            'saved'.tr,
            '${t.invoiceTitle} $invoiceNo ${'saved_to_device'.tr}',
            backgroundColor: const Color(0xFF16A34A),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
          break;
        default:
          await Share.shareXFiles(
            [xFile],
            text: '${t.invoiceTitle} $invoiceNo\n${t.grandTotal}: AED ${grandTotal.toStringAsFixed(2)}',
            subject: '${t.invoiceTitle} $invoiceNo',
          );
      }

      // Clear cart after successful invoice
      clearCart();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isGenerating.value = false;
    }
  }

  pw.Widget _pdfTotalRow(
      String label, String value,
      pw.Font labelFont, pw.Font valueFont, {
        bool highlight = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: labelFont,
                  fontSize: highlight ? 13 : 11,
                  color: highlight
                      ? PdfColor.fromHex('2563EB')
                      : PdfColor.fromHex('374151'))),
          pw.Text(value,
              style: pw.TextStyle(
                  font: valueFont,
                  fontSize: highlight ? 13 : 11,
                  color: highlight
                      ? PdfColor.fromHex('2563EB')
                      : PdfColor.fromHex('111827'))),
        ],
      ),
    );
  }
}

// ── Invoice translation strings ────────────────────────────
class _InvoiceTranslations {
  final String locale;
  _InvoiceTranslations(this.locale);

  String get invoiceTitle => locale == 'ar'
      ? 'فاتورة'
      : locale == 'ur'
      ? 'انوائس'
      : 'INVOICE';

  String get billTo => locale == 'ar'
      ? 'فاتورة إلى'
      : locale == 'ur'
      ? 'بل ٹو'
      : 'Bill To';

  String get product => locale == 'ar'
      ? 'المنتج'
      : locale == 'ur'
      ? 'مصنوعہ'
      : 'Product';

  String get qty => locale == 'ar'
      ? 'الكمية'
      : locale == 'ur'
      ? 'مقدار'
      : 'Qty';

  String get unitPrice => locale == 'ar'
      ? 'سعر الوحدة'
      : locale == 'ur'
      ? 'یونٹ قیمت'
      : 'Unit Price';

  String get total => locale == 'ar'
      ? 'المجموع'
      : locale == 'ur'
      ? 'کل'
      : 'Total';

  String get subtotal => locale == 'ar'
      ? 'المجموع الفرعي'
      : locale == 'ur'
      ? 'ذیلی کل'
      : 'Subtotal';

  String get vat => locale == 'ar'
      ? 'ضريبة القيمة المضافة'
      : locale == 'ur'
      ? 'ویٹ'
      : 'VAT';

  String get grandTotal => locale == 'ar'
      ? 'الإجمالي الكلي'
      : locale == 'ur'
      ? 'کل رقم'
      : 'Grand Total';

  String get note => locale == 'ar'
      ? 'ملاحظة'
      : locale == 'ur'
      ? 'نوٹ'
      : 'Note';

  String get thankYou => locale == 'ar'
      ? 'شكراً لتعاملكم معنا'
      : locale == 'ur'
      ? 'آپ کا شکریہ'
      : 'Thank you for your business!';
}