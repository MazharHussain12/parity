// ============================================================
// FILE: lib/controllers/invoice_controller.dart
// ============================================================

import 'package:get/get.dart';
import '../models/app_models.dart';

class InvoiceController extends GetxController {
  final Invoice currentInvoice = Invoice(
    invoiceNo: 'INV-10026',
    date: DateTime(2024, 5, 24, 10, 30),
    billToName: 'Walk-in Customer',
    billToAddress: 'Dubai, UAE',
    billToPhone: '+971 50 123 4567',
    billFromName: 'ABC Trading Co.',
    billFromAddress: 'Dubai, UAE',
    billFromTrn: '123456789012345',
    items: const [
      InvoiceItem(name: 'iPhone 15 Pro',   qty: 1, price: 4299.00),
      InvoiceItem(name: 'Sony Headphones', qty: 1, price: 350.00),
      InvoiceItem(name: 'Blue Pen',        qty: 2, price: 1.50),
    ],
    discount: 100.00,
    vatRate: 0.05,
    paymentMethod: 'Cash',
    status: InvoiceStatus.paid,
  );
}
