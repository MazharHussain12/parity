// ============================================================
// FILE: lib/widgets/common/language_picker.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language_rounded, color: AppColors.textOnPrimary),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: ctrl.changeLocale,
      itemBuilder: (_) => AppLocale.supported.map((l) {
        return PopupMenuItem<Locale>(
          value: l['locale'] as Locale,
          child: Obx(() {
            final isSelected = ctrl.currentLocale.value == l['locale'];
            return Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l['nativeName'] as String,
                        style: AppTextStyles.h4.copyWith(fontSize: 13)),
                    Text(l['name'] as String, style: AppTextStyles.label),
                  ],
                ),
              ],
            );
          }),
        );
      }).toList(),
    );
  }
}
