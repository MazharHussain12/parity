// ============================================================
// FILE: lib/controllers/products_controller.dart
// ============================================================

import 'package:get/get.dart';
import '../models/app_models.dart';

class ProductsController extends GetxController {
  final RxInt    selectedTab  = 0.obs;
  final RxString searchQuery  = ''.obs;

  // ── Made RxList so stock changes propagate reactively ──
  final RxList<Product> allProducts = <Product>[
    Product(id: '1', name: 'iPhone 15 Pro',  category: 'electronics',
        quantity: 25, price: 4299,  stockStatus: StockStatus.inStock,    imageEmoji: '📱'),
    Product(id: '2', name: 'Dell Laptop',     category: 'electronics',
        quantity: 12, price: 2850,  stockStatus: StockStatus.inStock,    imageEmoji: '💻'),
    Product(id: '3', name: 'Sony Headphones', category: 'electronics',
        quantity: 5,  price: 350,   stockStatus: StockStatus.lowStock,   imageEmoji: '🎧'),
    Product(id: '4', name: 'Office Chair',    category: 'furniture',
        quantity: 18, price: 150,   stockStatus: StockStatus.inStock,    imageEmoji: '🪑'),
    Product(id: '5', name: 'Wooden Table',    category: 'furniture',
        quantity: 3,  price: 320,   stockStatus: StockStatus.lowStock,   imageEmoji: '🪵'),
    Product(id: '6', name: 'Note Book',       category: 'stationery',
        quantity: 50, price: 5,     stockStatus: StockStatus.inStock,    imageEmoji: '📓'),
    Product(id: '7', name: 'Blue Pen',        category: 'stationery',
        quantity: 100, price: 1.50, stockStatus: StockStatus.inStock,    imageEmoji: '🖊️'),
  ].obs;

  List<Product> get filteredProducts {
    final q = searchQuery.value.toLowerCase();
    return allProducts.where((p) {
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchTab = selectedTab.value == 0 ||
          (selectedTab.value == 1 && p.stockStatus == StockStatus.inStock)    ||
          (selectedTab.value == 2 && p.stockStatus == StockStatus.lowStock)   ||
          (selectedTab.value == 3 && p.stockStatus == StockStatus.outOfStock);
      return matchSearch && matchTab;
    }).toList();
  }

  void setTab(int i)    => selectedTab.value = i;
  void setSearch(String q) => searchQuery.value = q;

  // ── Add stock to a product and recompute its status ────
  void addStock(String productId, int qty) {
    final idx = allProducts.indexWhere((p) => p.id == productId);
    if (idx == -1) return;

    final old      = allProducts[idx];
    final newQty   = old.quantity + qty;
    final newStatus = newQty == 0
        ? StockStatus.outOfStock
        : newQty <= 5
        ? StockStatus.lowStock
        : StockStatus.inStock;

    allProducts[idx] = Product(
      id:          old.id,
      name:        old.name,
      category:    old.category,
      quantity:    newQty,
      price:       old.price,
      stockStatus: newStatus,
      imageEmoji:  old.imageEmoji,
    );
    allProducts.refresh(); // notify Obx listeners
  }

  // ── Deduct stock (used by POS on sale) ─────────────────
  void deductStock(String productId, int qty) {
    final idx = allProducts.indexWhere((p) => p.id == productId);
    if (idx == -1) return;

    final old    = allProducts[idx];
    final newQty = (old.quantity - qty).clamp(0, 9999);
    final newStatus = newQty == 0
        ? StockStatus.outOfStock
        : newQty <= 5
        ? StockStatus.lowStock
        : StockStatus.inStock;

    allProducts[idx] = Product(
      id:          old.id,
      name:        old.name,
      category:    old.category,
      quantity:    newQty,
      price:       old.price,
      stockStatus: newStatus,
      imageEmoji:  old.imageEmoji,
    );
    allProducts.refresh();
  }
}