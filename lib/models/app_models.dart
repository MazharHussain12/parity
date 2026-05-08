// // ============================================================
// // FILE: lib/models/app_models.dart
// // ============================================================
//
// // ── Transaction ───────────────────────────────────────────
// class Transaction {
//   final String id;
//   final String customer;
//   final double amount;
//   final TransactionStatus status;
//   final DateTime date;
//
//   const Transaction({
//     required this.id,
//     required this.customer,
//     required this.amount,
//     required this.status,
//     required this.date,
//   });
// }
//
// enum TransactionStatus { paid, pending, cancelled }
//
// // ── Product ───────────────────────────────────────────────
// class Product {
//   final String id;
//   final String name;
//   final String category;
//   final int quantity;
//   final double price;
//   final StockStatus stockStatus;
//   final String imageEmoji;
//
//   const Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.quantity,
//     required this.price,
//     required this.stockStatus,
//     required this.imageEmoji,
//   });
// }
//
// enum StockStatus { inStock, lowStock, outOfStock }
//
// // ── Invoice Item ──────────────────────────────────────────
// class InvoiceItem {
//   final String name;
//   final int qty;
//   final double price;
//
//   const InvoiceItem({
//     required this.name,
//     required this.qty,
//     required this.price,
//   });
//
//   double get total => qty * price;
// }
//
// // ── Invoice ───────────────────────────────────────────────
// class Invoice {
//   final String invoiceNo;
//   final DateTime date;
//   final String billToName;
//   final String billToAddress;
//   final String billToPhone;
//   final String billFromName;
//   final String billFromAddress;
//   final String billFromTrn;
//   final List<InvoiceItem> items;
//   final double discount;
//   final double vatRate;
//   final String paymentMethod;
//   final InvoiceStatus status;
//
//   const Invoice({
//     required this.invoiceNo,
//     required this.date,
//     required this.billToName,
//     required this.billToAddress,
//     required this.billToPhone,
//     required this.billFromName,
//     required this.billFromAddress,
//     required this.billFromTrn,
//     required this.items,
//     required this.discount,
//     required this.vatRate,
//     required this.paymentMethod,
//     required this.status,
//   });
//
//   double get subtotal => items.fold(0, (s, i) => s + i.total);
//   double get vatAmount => (subtotal - discount) * vatRate;
//   double get total => subtotal - discount + vatAmount;
// }
//
//
// enum InvoiceStatus { paid, pending, cancelled }
