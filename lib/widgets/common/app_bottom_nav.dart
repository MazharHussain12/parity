// ============================================================
// FILE: lib/widgets/common/app_bottom_nav.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

    final items = [
      {'icon': Icons.home_rounded,       'label': 'nav_dashboard'},
      {'icon': Icons.inventory_2_rounded,'label': 'nav_products'},
      {'icon': Icons.receipt_long_rounded,'label': 'nav_sales'},
      {'icon': Icons.people_rounded,     'label': 'nav_customers'},
    ];

    return Obx(() => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length + 1, (i) {
              // FAB in the middle
              if (i == 2) {
                return Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.navFab,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x401A56DB),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                );
              }
              final idx = i > 2 ? i - 1 : i;
              final item = items[idx] as Map<String, dynamic>;
              final isActive = ctrl.currentNavIndex.value == idx;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ctrl.setNavIndex(idx),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isActive ? AppColors.navActive : AppColors.navInactive,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (item['label'] as String).tr,
                        style: AppTextStyles.navLabel.copyWith(
                          color: isActive ? AppColors.navActive : AppColors.navInactive,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ));
  }
}
