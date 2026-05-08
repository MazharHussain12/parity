// ============================================================
// FILE: lib/controllers/invoice_controller.dart
// ============================================================

import 'package:get/get.dart';
import '../models/appNew_models.dart';
import '../models/app_models.dart';

class InvoiceController extends GetxController {
  // Current invoice displayed on InvoiceScreen.
  // In production replace this with a parameter passed via Get.arguments
  // or loaded from a local database by invoiceNo.
  final Rx<Invoice> _current = Rx<Invoice>(_placeholder());

  Invoice get currentInvoice => _current.value;

  /// Call this before navigating to InvoiceScreen to set the invoice to display.
  void setInvoice(Invoice invoice) => _current.value = invoice;

  /// Build an Invoice from a completed POS sale and open the screen.
  Invoice buildFromSale({
    required String        invoiceNo,
    required List<InvoiceItem> items,
    required String        customerName,
    required String        paymentMethod,
    required String        businessName,
    required String        businessAddress,
    required String        businessTrn,
    double discount = 0.0,
  }) {
    final inv = Invoice(
      invoiceNo:       invoiceNo,
      date:            DateTime.now(),
      billToName:      customerName.isEmpty ? 'Walk-in Customer' : customerName,
      billToAddress:   '',
      billToPhone:     '',
      billFromName:    businessName,
      billFromAddress: businessAddress,
      billFromTrn:     businessTrn,
      items:           items,
      discount:        discount,
      vatRate:         0.05,
      paymentMethod:   paymentMethod,
      status:          InvoiceStatus.paid,
    );
    _current.value = inv;
    return inv;
  }

  // ── Demo / placeholder invoice ─────────────────────────
  static Invoice _placeholder() => Invoice(
    invoiceNo:       'INV-10026',
    date:            DateTime(2024, 5, 24, 10, 30),
    billToName:      'Walk-in Customer',
    billToAddress:   'Dubai, UAE',
    billToPhone:     '+971 50 123 4567',
    billFromName:    'ABC Trading Co.',
    billFromAddress: 'Dubai, UAE',
    billFromTrn:     '123456789012345',
    items: const [
      InvoiceItem(name: 'iPhone 15 Pro',   qty: 1, price: 4299.00),
      InvoiceItem(name: 'Sony Headphones', qty: 1, price: 350.00),
      InvoiceItem(name: 'Blue Pen',        qty: 2, price: 1.50),
    ],
    discount:      100.00,
    vatRate:       0.05,
    paymentMethod: 'Cash',
    status:        InvoiceStatus.paid,
  );
}