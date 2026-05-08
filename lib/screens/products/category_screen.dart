// ============================================================
// FILE: lib/screens/categories/categories_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/products_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appNew_models.dart';
import '../products/products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  CategoryController get _catCtrl {
    if (!Get.isRegistered<CategoryController>()) Get.put(CategoryController());
    return Get.find<CategoryController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _catCtrl;
    final prodCtrl = Get.isRegistered<ProductsController>()
        ? Get.find<ProductsController>()
        : Get.put(ProductsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GetBuilder<AppController>(
                          builder: (_) => Text('categories'.tr,
                              style: AppTextStyles.h2),
                        ),
                        Obx(() => Text(
                          '${ctrl.categories.length} ${'categories_count'.tr}',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textSecondary),
                        )),
                      ],
                    ),
                  ),
                  _AddCategoryButton(ctrl: ctrl),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Empty state or grid ──────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.categories.isEmpty) {
                  return _EmptyCategories(ctrl: ctrl);
                }
                return _CategoriesGrid(ctrl: ctrl, prodCtrl: prodCtrl);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────
class _EmptyCategories extends StatelessWidget {
  final CategoryController ctrl;
  const _EmptyCategories({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('📦', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 24),
            GetBuilder<AppController>(
              builder: (_) => Text('no_categories_yet'.tr,
                  style: AppTextStyles.h3, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            GetBuilder<AppController>(
              builder: (_) => Text('no_categories_desc'.tr,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _showCategorySheet(context, ctrl: ctrl),
              icon:  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: GetBuilder<AppController>(
                builder: (_) =>
                    Text('add_first_category'.tr, style: AppTextStyles.button),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Categories grid ────────────────────────────────────────
class _CategoriesGrid extends StatelessWidget {
  final CategoryController ctrl;
  final ProductsController prodCtrl;
  const _CategoriesGrid({required this.ctrl, required this.prodCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = ctrl.categories;
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing:  12,
        ),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final cat       = cats[i];
          final color     = Color(cat.colorValue);
          final prodCount = prodCtrl.productsByCategory(cat.id).length;
          return _CategoryCard(
            category:  cat,
            color:     color,
            prodCount: prodCount,
            onTap:    () => Get.to(() => ProductsScreen(filterCategoryId: cat.id)),
            onEdit:   () => _showCategorySheet(context, ctrl: ctrl, editing: cat),
            onDelete: () => _confirmDelete(context, ctrl: ctrl, cat: cat),
          );
        },
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final Color           color;
  final int             prodCount;
  final VoidCallback    onTap;
  final VoidCallback    onEdit;
  final VoidCallback    onDelete;

  const _CategoryCard({
    required this.category,
    required this.color,
    required this.prodCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border:       Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:      color.withOpacity(0.08),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(category.emoji,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textHint, size: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text('edit'.tr),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Text('delete'.tr,
                          style: const TextStyle(color: AppColors.danger)),
                    ]),
                  ),
                ],
              ),
            ]),
            const Spacer(),
            Text(category.name,
                style: AppTextStyles.h4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            GetBuilder<AppController>(
              builder: (_) => Text(
                '$prodCount ${'products_count'.tr}',
                style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add category button ────────────────────────────────────
class _AddCategoryButton extends StatelessWidget {
  final CategoryController ctrl;
  const _AddCategoryButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showCategorySheet(context, ctrl: ctrl),
      icon:  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      label: GetBuilder<AppController>(
        builder: (_) =>
            Text('add_category'.tr, style: AppTextStyles.button),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Category bottom sheet ──────────────────────────────────
// FIX: Converted to a StatefulWidget so the TextEditingController is
// properly owned and disposed, and the sheet always clears + pops correctly.
void _showCategorySheet(
    BuildContext context, {
      required CategoryController ctrl,
      ProductCategory? editing,
    }) {
  showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    // FIX: use a StatefulWidget inner sheet — keeps Obx local observables
    // scoped correctly so GetX can track them without the "improper use" crash.
    builder: (_) => _CategorySheet(ctrl: ctrl, editing: editing),
  );
}

class _CategorySheet extends StatefulWidget {
  final CategoryController ctrl;
  final ProductCategory?   editing;
  const _CategorySheet({required this.ctrl, this.editing});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final TextEditingController _nameCtrl;
  // FIX: local .obs variables scoped inside this StatefulWidget —
  // GetX can track them reliably because they're created here, not
  // in a plain function where the scope is ambiguous.
  late final RxString _selEmoji;
  late final RxInt    _selColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.editing?.name ?? '');
    _selEmoji = (widget.editing?.emoji   ?? '📦').obs;
    _selColor = (widget.editing?.colorValue ??
        CategoryController.colorOptions.first).obs;
  }

  @override
  void dispose() {
    // FIX: always dispose the TextEditingController to avoid memory leaks
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    if (widget.editing != null) {
      widget.ctrl.updateCategory(
        id:         widget.editing!.id,
        name:       name,
        emoji:      _selEmoji.value,
        colorValue: _selColor.value,
      );
    } else {
      widget.ctrl.addCategory(
        name:       name,
        emoji:      _selEmoji.value,
        colorValue: _selColor.value,
      );
    }

    // FIX: clear field first, then close the sheet
    _nameCtrl.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin:  const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            GetBuilder<AppController>(
              builder: (_) => Text(
                widget.editing != null
                    ? 'edit_category'.tr
                    : 'new_category'.tr,
                style: AppTextStyles.h3,
              ),
            ),
            const SizedBox(height: 20),

            // ── Preview circle ──────────────────────────
            // FIX: single Obx reads both _selEmoji and _selColor — correct
            // because both observables are accessed in the same builder scope.
            Obx(() => Center(
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Color(_selColor.value).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Color(_selColor.value).withOpacity(0.4),
                      width: 2),
                ),
                child: Center(
                  child: Text(_selEmoji.value,
                      style: const TextStyle(fontSize: 34)),
                ),
              ),
            )),
            const SizedBox(height: 20),

            // ── Name field ──────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              style:      AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText:  'category_name_hint'.tr,
                hintStyle: AppTextStyles.label,
                filled:    true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // ── Emoji label ─────────────────────────────
            Text('choose_emoji'.tr,
                style: AppTextStyles.label
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // ── Emoji picker ────────────────────────────
            // FIX: separate Obx for emoji list — reads _selEmoji and
            // _selColor independently so GetX tracks each correctly.
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:       CategoryController.emojiOptions.length,
                itemBuilder: (_, i) {
                  final e = CategoryController.emojiOptions[i];
                  // Each item gets its own small Obx to track selection state
                  return Obx(() {
                    final sel        = _selEmoji.value == e;
                    final colorValue = _selColor.value; // read here for border color
                    return GestureDetector(
                      onTap: () => _selEmoji.value = e,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin:  const EdgeInsets.only(right: 8),
                        width:   44,
                        height:  44,
                        decoration: BoxDecoration(
                          color: sel
                              ? Color(colorValue).withOpacity(0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: sel
                              ? Border.all(
                              color: Color(colorValue), width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(e,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Color label ─────────────────────────────
            Text('choose_color'.tr,
                style: AppTextStyles.label
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // ── Color picker ────────────────────────────
            // FIX: separate Obx just for color — reads only _selColor
            Obx(() => Wrap(
              spacing:    10,
              runSpacing: 10,
              children: CategoryController.colorOptions.map((c) {
                final sel = _selColor.value == c;
                return GestureDetector(
                  onTap: () => _selColor.value = c,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width:  34,
                    height: 34,
                    decoration: BoxDecoration(
                      color:  Color(c),
                      shape:  BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: sel
                          ? [BoxShadow(
                          color:      Color(c).withOpacity(0.5),
                          blurRadius: 8)]
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 28),

            // ── Save button ─────────────────────────────
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: GetBuilder<AppController>(
                  builder: (_) => Text(
                    widget.editing != null
                        ? 'save_changes'.tr
                        : 'create_category'.tr,
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Confirm delete dialog ──────────────────────────────────
void _confirmDelete(
    BuildContext context, {
      required CategoryController ctrl,
      required ProductCategory    cat,
    }) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('delete_category'.tr, style: AppTextStyles.h3),
      content: GetBuilder<AppController>(
        builder: (_) => Text(
          '${'delete_category_confirm'.tr} "${cat.name}"?\n${'delete_category_warning'.tr}',
          style: AppTextStyles.bodyMd,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: GetBuilder<AppController>(
              builder: (_) => Text('cancel'.tr)),
        ),
        ElevatedButton(
          onPressed: () {
            ctrl.deleteCategory(cat.id);
            Get.back();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger, elevation: 0),
          child: GetBuilder<AppController>(
            builder: (_) => Text('delete'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}