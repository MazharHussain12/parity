// ============================================================
// FILE: lib/models/app_models.dart
// ============================================================

// ── Auth / Business ────────────────────────────────────────
class BusinessUser {
  final String   id;
  final String   businessName;
  final String   ownerName;
  final String   email;
  final String   phone;
  final String?  logoPath;
  final DateTime createdAt;

  const BusinessUser({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.logoPath,
    required this.createdAt,
  });

  BusinessUser copyWith({
    String? businessName,
    String? ownerName,
    String? email,
    String? phone,
    String? logoPath,
  }) =>
      BusinessUser(
        id:           id,
        businessName: businessName ?? this.businessName,
        ownerName:    ownerName    ?? this.ownerName,
        email:        email        ?? this.email,
        phone:        phone        ?? this.phone,
        logoPath:     logoPath     ?? this.logoPath,
        createdAt:    createdAt,
      );
}

// ── Category ───────────────────────────────────────────────
class ProductCategory {
  final String   id;
  final String   name;
  final String   emoji;
  final int      colorValue;
  final DateTime createdAt;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.createdAt,
  });

  ProductCategory copyWith({
    String? name,
    String? emoji,
    int?    colorValue,
  }) =>
      ProductCategory(
        id:         id,
        name:       name       ?? this.name,
        emoji:      emoji      ?? this.emoji,
        colorValue: colorValue ?? this.colorValue,
        createdAt:  createdAt,
      );
}

// ── Product ────────────────────────────────────────────────
enum StockStatus { inStock, lowStock, outOfStock }

class Product {
  final String      id;
  final String      name;
  final String      brand;
  final String      categoryId;
  final String      categoryName;
  final double      price;
  final double      costPrice;
  final int         quantity;
  final int         lowStockThreshold;
  final StockStatus stockStatus;
  final String?     imagePath;
  final String      barcode;
  final String      unit;
  final String      description;
  final DateTime    createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.costPrice,
    required this.quantity,
    this.lowStockThreshold = 5,
    required this.stockStatus,
    this.imagePath,
    required this.barcode,
    required this.unit,
    required this.description,
    required this.createdAt,
  });

  Product copyWith({
    String?      name,
    String?      brand,
    String?      categoryId,
    String?      categoryName,
    double?      price,
    double?      costPrice,
    int?         quantity,
    int?         lowStockThreshold,
    StockStatus? stockStatus,
    String?      imagePath,
    String?      barcode,
    String?      unit,
    String?      description,
  }) =>
      Product(
        id:                id,
        name:              name              ?? this.name,
        brand:             brand             ?? this.brand,
        categoryId:        categoryId        ?? this.categoryId,
        categoryName:      categoryName      ?? this.categoryName,
        price:             price             ?? this.price,
        costPrice:         costPrice         ?? this.costPrice,
        quantity:          quantity          ?? this.quantity,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        stockStatus:       stockStatus       ?? this.stockStatus,
        imagePath:         imagePath         ?? this.imagePath,
        barcode:           barcode           ?? this.barcode,
        unit:              unit              ?? this.unit,
        description:       description       ?? this.description,
        createdAt:         createdAt,
      );
}

// ── Transaction ────────────────────────────────────────────
enum TransactionStatus { paid, pending, cancelled }

class Transaction {
  final String            id;
  final String            customer;
  final double            amount;
  final TransactionStatus status;
  final DateTime          date;

  const Transaction({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
  });
}

// ── Stock Movement ─────────────────────────────────────────
class StockMovement {
  final String   productId;
  final String   productName;
  final int      qty;
  final String   note;
  final DateTime date;

  const StockMovement({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.note,
    required this.date,
  });
}

// ── Invoice ────────────────────────────────────────────────
enum InvoiceStatus { paid, pending, cancelled }

class InvoiceItem {
  final String name;
  final int    qty;
  final double price;

  const InvoiceItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  double get total => qty * price;
}

class Invoice {
  final String        invoiceNo;
  final DateTime      date;
  final String        billToName;
  final String        billToAddress;
  final String        billToPhone;
  final String        billFromName;
  final String        billFromAddress;
  final String        billFromTrn;
  final List<InvoiceItem> items;
  final double        discount;
  final double        vatRate;
  final String        paymentMethod;
  final InvoiceStatus status;

  const Invoice({
    required this.invoiceNo,
    required this.date,
    required this.billToName,
    required this.billToAddress,
    required this.billToPhone,
    required this.billFromName,
    required this.billFromAddress,
    required this.billFromTrn,
    required this.items,
    this.discount      = 0.0,
    this.vatRate       = 0.05,
    required this.paymentMethod,
    required this.status,
  });

  double get subtotal  => items.fold(0.0, (s, i) => s + i.total);
  double get vatAmount => (subtotal - discount) * vatRate;
  double get total     => subtotal - discount + vatAmount;
}