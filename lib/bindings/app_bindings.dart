// ============================================================
// ADD to your bindings file (e.g. lib/bindings/app_bindings.dart)
// or wherever you register GetX controllers
// ============================================================

import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../controllers/pos_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ... your existing registrations ...

    // ADD THESE:
    Get.lazyPut<StockController>(() => StockController(), fenix: true);
    Get.lazyPut<PosController>(() => PosController(), fenix: true);
  }
}

// ============================================================
// Also ensure ProductsController uses the UPDATED version
// (allProducts is now RxList instead of plain List)
// ============================================================