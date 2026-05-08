// ============================================================
// FILE: lib/screens/home_shell.dart
// PURPOSE: Root scaffold with bottom navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/products_controller.dart';
import '../controllers/invoice_controller.dart';
import '../widgets/common/app_bottom_nav.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/products_screen.dart';
import 'sales/sales_screen.dart' hide CustomersScreen;
import 'customers/customers_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    // Register all controllers
    Get.put(AppController());
    Get.put(DashboardController());
    Get.put(ProductsController());
    Get.put(InvoiceController());
  }

  final _screens = const [
    DashboardScreen(),
    ProductsScreen(),
    SalesScreen(),
    CustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: appCtrl.currentNavIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: const AppBottomNav(),
        ));
  }
}
