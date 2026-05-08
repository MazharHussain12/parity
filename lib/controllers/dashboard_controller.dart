// ============================================================
// FILE: lib/controllers/dashboard_controller.dart
// ============================================================

import 'package:get/get.dart';
import '../models/app_models.dart';

class DashboardController extends GetxController {
  final RxString selectedPeriod = 'this_week'.obs;

  final double totalSales  = 4850.00;
  final double totalProfit = 1650.00;
  final int totalOrders    = 28;
  final int lowStockItems  = 7;

  final double salesChange  = 12.5;
  final double profitChange = 8.2;
  final int ordersChange    = 3;

  final List<double> weeklyData = [1800, 2200, 2100, 3100, 2800, 3400, 4700];

  final List<Transaction> recentTransactions = [
    Transaction(
      id: 'INV-10025',
      customer: 'Walk-in Customer',
      amount: 250.00,
      status: TransactionStatus.paid,
      date: DateTime.now(),
    ),
    Transaction(
      id: 'INV-10024',
      customer: 'Ahmed Khan',
      amount: 550.00,
      status: TransactionStatus.paid,
      date: DateTime.now(),
    ),
    Transaction(
      id: 'INV-10023',
      customer: 'Sara Ali',
      amount: 175.00,
      status: TransactionStatus.pending,
      date: DateTime.now(),
    ),
  ];
}
