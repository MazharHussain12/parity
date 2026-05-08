// ============================================================
// FILE: lib/screens/products/add_edit_product_screen.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/products_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appNew_models.dart' show Product, ProductCategory;
import '../../models/app_models.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? editing;
  final String?  defaultCategoryId;
  const AddEditProductScreen({super.key, this.editing, this.defaultCategoryId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _brandCtrl   = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _costCtrl    = TextEditingController();
  final _qtyCtrl     = TextEditingController();
  final _threshCtrl  = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();

  String  _selectedCategoryId = '';
  String  _selectedUnit       = 'pcs';
  String? _imagePath;
  bool    _isLoading          = false;

  static const List<String> _units = [
    'pcs','kg','g','ltr','ml','box','pack','dozen','pair','set',
  ];

  late final ProductsController _prodCtrl;
  late final CategoryController _catCtrl;

  @override
  void initState() {
    super.initState();
    _prodCtrl = Get.isRegistered<ProductsController>()
        ? Get.find<ProductsController>()
        : Get.put(ProductsController());
    _catCtrl = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());

    final e = widget.editing;
    if (e != null) {
      _nameCtrl.text    = e.name;
      _brandCtrl.text   = e.brand;
      _priceCtrl.text   = e.price.toStringAsFixed(2);
      _costCtrl.text    = e.costPrice.toStringAsFixed(2);
      _qtyCtrl.text     = '${e.quantity}';
      _threshCtrl.text  = '${e.lowStockThreshold}';
      _barcodeCtrl.text = e.barcode;
      _descCtrl.text    = e.description;
      _selectedCategoryId = e.categoryId;
      _selectedUnit       = e.unit;
      _imagePath          = e.imagePath;
    } else {
      _selectedCategoryId =
          widget.defaultCategoryId ?? _catCtrl.categories.firstOrNull?.id ?? '';
      _threshCtrl.text = '5';
      _qtyCtrl.text    = '0';
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _brandCtrl, _priceCtrl, _costCtrl,
      _qtyCtrl, _threshCtrl, _barcodeCtrl, _descCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _prodCtrl.pickImage(source);
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      Get.snackbar('error'.tr, 'select_category_required'.tr,
          backgroundColor: AppColors.danger, colorText: Colors.white,
          snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (widget.editing != null) {
      _prodCtrl.updateProduct(widget.editing!.id,
        name:              _nameCtrl.text,
        brand:             _brandCtrl.text,
        categoryId:        _selectedCategoryId,
        price:             double.tryParse(_priceCtrl.text) ?? 0,
        costPrice:         double.tryParse(_costCtrl.text)  ?? 0,
        quantity:          int.tryParse(_qtyCtrl.text)      ?? 0,
        lowStockThreshold: int.tryParse(_threshCtrl.text)   ?? 5,
        barcode:           _barcodeCtrl.text,
        unit:              _selectedUnit,
        description:       _descCtrl.text,
        imagePath:         _imagePath,
      );
    } else {
      _prodCtrl.addProduct(
        name:              _nameCtrl.text,
        brand:             _brandCtrl.text,
        categoryId:        _selectedCategoryId,
        price:             double.tryParse(_priceCtrl.text) ?? 0,
        costPrice:         double.tryParse(_costCtrl.text)  ?? 0,
        quantity:          int.tryParse(_qtyCtrl.text)      ?? 0,
        lowStockThreshold: int.tryParse(_threshCtrl.text)   ?? 5,
        barcode:           _barcodeCtrl.text,
        unit:              _selectedUnit,
        description:       _descCtrl.text,
        imagePath:         _imagePath,
      );
    }
    setState(() => _isLoading = false);
    Get.back();
    Get.snackbar(
      'success'.tr,
      widget.editing != null ? 'product_updated'.tr : 'product_added'.tr,
      backgroundColor: const Color(0xFF16A34A),
      colorText:       Colors.white,
      snackPosition:   SnackPosition.TOP,
      margin:          const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: Get.back,
        ),
        title: GetBuilder<AppController>(
          builder: (_) => Text(
            isEditing ? 'edit_product'.tr : 'add_product'.tr,
            style: AppTextStyles.h3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product image ────────────────────────
              _ImageSection(
                imagePath: _imagePath,
                onCamera:  () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
                onClear:   () => setState(() => _imagePath = null),
              ),
              const SizedBox(height: 24),

              // ── Basic info ───────────────────────────
              _SectionHeader(title: 'basic_info'.tr),
              const SizedBox(height: 14),
              _FieldLabel(label: 'product_name'.tr, required: true),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameCtrl,
                hint:       'product_name_hint'.tr,
                icon:       Icons.inventory_2_outlined,
                validator:  (v) => v == null || v.trim().isEmpty
                    ? 'product_name_required'.tr : null,
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: 'brand'.tr),
              const SizedBox(height: 8),
              _buildField(
                controller: _brandCtrl,
                hint:       'brand_hint'.tr,
                icon:       Icons.branding_watermark_outlined,
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: 'description'.tr),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines:   3,
                style:      AppTextStyles.bodyMd,
                decoration: _decor(
                    hint: 'description_hint'.tr,
                    icon: Icons.notes_rounded),
              ),
              const SizedBox(height: 24),

              // ── Category ─────────────────────────────
              _SectionHeader(title: 'category'.tr),
              const SizedBox(height: 14),
              _CategorySelector(
                categories:         _catCtrl.categories,
                selectedCategoryId: _selectedCategoryId,
                onSelect: (id) => setState(() => _selectedCategoryId = id),
              ),
              const SizedBox(height: 24),

              // ── Pricing ──────────────────────────────
              _SectionHeader(title: 'pricing'.tr),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'selling_price'.tr, required: true),
                    const SizedBox(height: 8),
                    _buildField(
                      controller:      _priceCtrl,
                      hint:            '0.00',
                      icon:            Icons.sell_outlined,
                      keyboardType:    const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (v) => v == null || v.isEmpty
                          ? 'price_required'.tr : null,
                      prefix: 'AED ',
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'cost_price'.tr),
                    const SizedBox(height: 8),
                    _buildField(
                      controller:      _costCtrl,
                      hint:            '0.00',
                      icon:            Icons.price_change_outlined,
                      keyboardType:    const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))],
                      prefix: 'AED ',
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 24),

              // ── Stock info ───────────────────────────
              _SectionHeader(title: 'stock_info'.tr),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'initial_qty'.tr),
                    const SizedBox(height: 8),
                    _buildField(
                      controller:      _qtyCtrl,
                      hint:            '0',
                      icon:            Icons.inventory_outlined,
                      keyboardType:    TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'low_stock_threshold'.tr),
                    const SizedBox(height: 8),
                    _buildField(
                      controller:      _threshCtrl,
                      hint:            '5',
                      icon:            Icons.warning_amber_outlined,
                      keyboardType:    TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 16),
              _FieldLabel(label: 'unit'.tr),
              const SizedBox(height: 8),
              _UnitSelector(
                selected: _selectedUnit,
                units:    _units,
                onSelect: (u) => setState(() => _selectedUnit = u),
              ),
              const SizedBox(height: 24),

              // ── Additional info ──────────────────────
              _SectionHeader(title: 'additional_info'.tr),
              const SizedBox(height: 14),
              _FieldLabel(label: 'barcode'.tr),
              const SizedBox(height: 8),
              _buildField(
                controller:   _barcodeCtrl,
                hint:         'barcode_hint'.tr,
                icon:         Icons.qr_code_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 36),

              // ── Save button ──────────────────────────
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation:       0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : GetBuilder<AppController>(
                    builder: (_) => Text(
                      isEditing ? 'save_changes'.tr : 'add_product'.tr,
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decor({
    required String hint,
    required IconData icon,
    String? prefix,
  }) =>
      InputDecoration(
        hintText:    hint,
        hintStyle:   AppTextStyles.label,
        prefixIcon:  Icon(icon, color: AppColors.textHint, size: 20),
        prefixText:  prefix,
        prefixStyle: AppTextStyles.label,
        filled:      true,
        fillColor:   AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.danger, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.danger, width: 1.5)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? prefix,
  }) =>
      TextFormField(
        controller:      controller,
        keyboardType:    keyboardType,
        inputFormatters: inputFormatters,
        validator:       validator,
        style:           AppTextStyles.bodyMd,
        decoration:      _decor(hint: hint, icon: icon, prefix: prefix),
      );
}

// ── Image section ──────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  final String?      imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  const _ImageSection({
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showOptions(context),
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color:        AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 2,
                  style: imagePath != null ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
              child: imagePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.textHint, size: 36),
                  const SizedBox(height: 6),
                  GetBuilder<AppController>(
                    builder: (_) => Text('add_photo'.tr,
                        style: AppTextStyles.caption),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallBtn(icon: Icons.camera_alt_outlined,
                  label: 'camera'.tr, onTap: onCamera),
              const SizedBox(width: 10),
              _SmallBtn(icon: Icons.photo_library_outlined,
                  label: 'gallery'.tr, onTap: onGallery),
              if (imagePath != null) ...[
                const SizedBox(width: 10),
                _SmallBtn(icon: Icons.delete_outline_rounded,
                    label: 'remove'.tr, onTap: onClear, isRed: true),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin:  const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title:   GetBuilder<AppController>(builder: (_) => Text('take_photo'.tr)),
              onTap: () { Get.back(); onCamera(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title:   GetBuilder<AppController>(builder: (_) => Text('choose_gallery'.tr)),
              onTap: () { Get.back(); onGallery(); },
            ),
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title:   GetBuilder<AppController>(
                  builder: (_) => Text('remove_photo'.tr,
                      style: const TextStyle(color: AppColors.danger)),
                ),
                onTap: () { Get.back(); onClear(); },
              ),
          ],
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback onTap; final bool isRed;
  const _SmallBtn({
    required this.icon, required this.label,
    required this.onTap, this.isRed = false,
  });
  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.danger : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ]),
      ),
    );
  }
}

// ── Category selector ──────────────────────────────────────
class _CategorySelector extends StatelessWidget {
  final List<ProductCategory> categories;
  final String                selectedCategoryId;
  final void Function(String) onSelect;
  const _CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:  AppColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: GetBuilder<AppController>(
              builder: (_) => Text('no_categories_warning'.tr,
                  style: AppTextStyles.bodySm),
            ),
          ),
        ]),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:       categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final sel = cat.id == selectedCategoryId;
          final col = Color(cat.colorValue);
          return GestureDetector(
            onTap: () => onSelect(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin:   const EdgeInsets.only(right: 8),
              padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        sel ? col : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: sel ? col : AppColors.border, width: 1),
              ),
              child: Row(children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(cat.name,
                    style: AppTextStyles.label.copyWith(
                      color:      sel ? Colors.white : AppColors.textPrimary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    )),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Unit selector ──────────────────────────────────────────
class _UnitSelector extends StatelessWidget {
  final String selected; final List<String> units;
  final void Function(String) onSelect;
  const _UnitSelector({
    required this.selected, required this.units, required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: units.map((u) {
      final sel = u == selected;
      return GestureDetector(
        onTap: () => onSelect(u),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:        sel ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(u,
              style: AppTextStyles.label.copyWith(
                color:      sel ? Colors.white : AppColors.textSecondary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
              )),
        ),
      );
    }).toList(),
  );
}

// ── Helpers ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 3, height: 18,
      decoration: BoxDecoration(
        color: AppColors.primary, borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 8),
    Text(title,
        style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary)),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String label; final bool required;
  const _FieldLabel({required this.label, this.required = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label,
        style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    if (required) ...[
      const SizedBox(width: 2),
      const Text('*',
          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
    ],
  ]);
}