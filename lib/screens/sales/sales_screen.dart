// ============================================================
// FILE: lib/screens/sales/sales_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../invoice/invoice_screen.dart';
import '../../controllers/invoice_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('nav_sales'.tr, style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) {
          final invoiceNum = 10030 - i;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text('INV-$invoiceNum', style: AppTextStyles.h4),
              subtitle: Text('Walk-in Customer\n24 May 2024',
                  style: AppTextStyles.label),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('AED ${(4500 - i * 300).toStringAsFixed(2)}',
                      style: AppTextStyles.price),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('paid'.tr,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              onTap: () {
                Get.put(InvoiceController());
                Get.to(() => const InvoiceScreen(),
                    transition: Transition.rightToLeft);
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// FILE: lib/screens/customers/customers_screen.dart
// ============================================================

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  final List<Map<String, String>> _customers = const [
    {'name': 'Ahmed Khan',       'phone': '+971 50 123 4567', 'total': '5,250.00'},
    {'name': 'Sara Ali',         'phone': '+971 55 987 6543', 'total': '1,800.00'},
    {'name': 'Mohammed Hassan',  'phone': '+971 52 456 7890', 'total': '3,400.00'},
    {'name': 'Fatima Al Zaabi',  'phone': '+971 56 234 5678', 'total': '920.00'},
    {'name': 'Walk-in Customer', 'phone': '-',                'total': '12,450.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('nav_customers'.tr, style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (_, i) {
          final c = _customers[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  c['name']![0],
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ),
              title: Text(c['name']!, style: AppTextStyles.h4),
              subtitle: Text(c['phone']!, style: AppTextStyles.label),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: AppTextStyles.caption),
                  Text('AED ${c['total']}', style: AppTextStyles.price),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
