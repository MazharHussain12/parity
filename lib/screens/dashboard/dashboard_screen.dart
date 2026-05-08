// ============================================================
// FILE: lib/screens/dashboard/dashboard_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_models.dart';
import '../../widgets/common/language_picker.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final appCtrl = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Blue header ──────────────────────────────────
          SliverToBoxAdapter(
            child: _DashboardHeader(ctrl: ctrl, appCtrl: appCtrl),
          ),
          // ── Content ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatsGrid(ctrl: ctrl),
                const SizedBox(height: 16),
                _SalesChart(ctrl: ctrl),
                const SizedBox(height: 16),
                _RecentTransactions(ctrl: ctrl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final DashboardController ctrl;
  final AppController appCtrl;
  const _DashboardHeader({required this.ctrl, required this.appCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FIX: .tr is not observable. GetBuilder<AppController>
                        // rebuilds whenever changeLocale() calls update().
                        GetBuilder<AppController>(
                          builder: (_) => Text(
                            '${'hello'.tr}, Ahmed 👋',
                            style: AppTextStyles.onPrimaryBold,
                          ),
                        ),
                        GetBuilder<AppController>(
                          builder: (_) => Text(
                            'app_name'.tr,
                            style: AppTextStyles.onPrimary
                                .copyWith(fontSize: 12, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguagePicker(),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Date pill
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    GetBuilder<AppController>(
                      builder: (_) => Text(
                        '${'today'.tr}, 24 May 2024',
                        style: AppTextStyles.onPrimary
                            .copyWith(fontSize: 13, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // KPI row — values are plain finals, no reactive wrapper needed
              // for data. GetBuilder only to re-translate labels on locale change.
              GetBuilder<AppController>(
                builder: (_) => Row(
                  children: [
                    Expanded(
                      child: _HeaderKpi(
                        label: 'total_sales'.tr,
                        amount: 'AED 4,850.00',
                        change: '+12.5%',
                        isProfit: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 56, color: Colors.white24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeaderKpi(
                        label: 'total_profit'.tr,
                        amount: 'AED 1,650.00',
                        change: '+8.2%',
                        isProfit: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderKpi extends StatelessWidget {
  final String label;
  final String amount;
  final String change;
  final bool isProfit;
  const _HeaderKpi({
    required this.label,
    required this.amount,
    required this.change,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.onPrimary
                .copyWith(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(amount,
            style: AppTextStyles.onPrimaryBold.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.trending_up_rounded,
                color: isProfit
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF93C5FD),
                size: 14),
            const SizedBox(width: 3),
            Text(change,
                style: AppTextStyles.onPrimary.copyWith(
                    fontSize: 12,
                    color: isProfit
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF93C5FD))),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'vs_yesterday'.tr,
                style: AppTextStyles.onPrimary
                    .copyWith(fontSize: 11, color: Colors.white54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stats grid ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final DashboardController ctrl;
  const _StatsGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // FIX: Removed Obx — totalOrders, lowStockItems, ordersChange are plain
    // final fields (not .obs). Obx with no observable inside throws the same
    // error. GetBuilder<AppController> only for label re-translation.
    return GetBuilder<AppController>(
      builder: (_) => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'total_orders'.tr,
              value: '${ctrl.totalOrders}',
              sub: '↑ ${ctrl.ordersChange} ${'vs_yesterday'.tr}',
              valueColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'low_stock_items'.tr,
              value: '${ctrl.lowStockItems}',
              sub: 'view_all'.tr,
              valueColor: AppColors.warning,
              subIsLink: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  final bool subIsLink;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
    this.subIsLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 6),
          Text(value,
              style:
              AppTextStyles.h2.copyWith(color: valueColor, fontSize: 22)),
          const SizedBox(height: 4),
          Text(sub,
              style: AppTextStyles.bodySm.copyWith(
                color:
                subIsLink ? AppColors.primary : AppColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

// ── Sales chart ───────────────────────────────────────────
class _SalesChart extends StatelessWidget {
  final DashboardController ctrl;
  const _SalesChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final data = ctrl.weeklyData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<AppController>(
                builder: (_) =>
                    Text('sales_overview'.tr, style: AppTextStyles.h4),
              ),
              // selectedPeriod IS .obs — Obx is correct and safe here
              Obx(() => GestureDetector(
                onTap: () {
                  ctrl.selectedPeriod.value =
                  ctrl.selectedPeriod.value == 'this_week'
                      ? 'this_month'
                      : 'this_week';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(ctrl.selectedPeriod.value.tr,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary)),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1000,
                      getTitlesWidget: (v, _) => Text(
                        '${(v / 1000).toStringAsFixed(0)}k',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(days[idx].tr,
                            style: AppTextStyles.caption);
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 5500,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        data.length, (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: AppColors.chartLine,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.chartFill,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.surface,
                        strokeColor: AppColors.chartDot,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent transactions ───────────────────────────────────
class _RecentTransactions extends StatelessWidget {
  final DashboardController ctrl;
  const _RecentTransactions({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // recentTransactions is a plain List — no Obx needed.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<AppController>(
                builder: (_) => Text(
                  'recent_transactions'.tr,
                  style: AppTextStyles.h4,
                ),
              ),
              GetBuilder<AppController>(
                builder: (_) => Text(
                  'view_all'.tr,
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ctrl.recentTransactions.map((t) => _TxRow(tx: t)),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Transaction tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPaid = tx.status == TransactionStatus.paid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.id, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(tx.customer, style: AppTextStyles.label),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('AED ${tx.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.h4),
              const SizedBox(height: 2),
              GetBuilder<AppController>(
                builder: (_) => Text(
                  isPaid ? 'paid'.tr : 'pending'.tr,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isPaid ? AppColors.accent : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}