// ============================================================
// FILE: lib/screens/auth/register_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _businessCtrl = TextEditingController();
  final _ownerCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool  _obscure      = true;
  bool  _obscureC     = true;

  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    for (final c in [_businessCtrl, _ownerCtrl, _emailCtrl,
      _phoneCtrl, _passwordCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.register(
      businessName: _businessCtrl.text,
      ownerName:    _ownerCtrl.text,
      email:        _emailCtrl.text,
      phone:        _phoneCtrl.text,
      password:     _passwordCtrl.text,
    );
    if (ok) Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('create_account'.tr,
                  style: AppTextStyles.h1.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text('register_subtitle'.tr,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              // ── Business info ─────────────────────────
              _SectionHeader(title: 'business_info'.tr),
              const SizedBox(height: 14),
              _FieldLabel(label: 'business_name'.tr),
              const SizedBox(height: 8),
              _FormField(
                controller: _businessCtrl,
                hint:       'business_name_hint'.tr,
                icon:       Icons.storefront_outlined,
                validator:  (v) => v == null || v.trim().isEmpty
                    ? 'business_name_required'.tr : null,
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: 'owner_name'.tr),
              const SizedBox(height: 8),
              _FormField(
                controller: _ownerCtrl,
                hint:       'owner_name_hint'.tr,
                icon:       Icons.person_outline_rounded,
              ),
              const SizedBox(height: 28),

              // ── Contact ───────────────────────────────
              _SectionHeader(title: 'contact_info'.tr),
              const SizedBox(height: 14),
              _FieldLabel(label: 'email'.tr),
              const SizedBox(height: 8),
              _FormField(
                controller:   _emailCtrl,
                hint:         'email_hint'.tr,
                icon:         Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator:    (v) => v == null || !GetUtils.isEmail(v)
                    ? 'valid_email_required'.tr : null,
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: 'phone'.tr),
              const SizedBox(height: 8),
              _FormField(
                controller:   _phoneCtrl,
                hint:         'phone_hint'.tr,
                icon:         Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // ── Security ──────────────────────────────
              _SectionHeader(title: 'security'.tr),
              const SizedBox(height: 14),
              _FieldLabel(label: 'password'.tr),
              const SizedBox(height: 8),
              TextFormField(
                controller:  _passwordCtrl,
                obscureText: _obscure,
                style:       AppTextStyles.bodyMd,
                decoration:  _decor(
                  hint: 'password_hint'.tr,
                  icon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textHint, size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                v == null || v.length < 6 ? 'password_min_6'.tr : null,
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: 'confirm_password'.tr),
              const SizedBox(height: 8),
              TextFormField(
                controller:  _confirmCtrl,
                obscureText: _obscureC,
                style:       AppTextStyles.bodyMd,
                decoration:  _decor(
                  hint: 'confirm_password_hint'.tr,
                  icon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureC ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textHint, size: 20,
                    ),
                    onPressed: () => setState(() => _obscureC = !_obscureC),
                  ),
                ),
                validator: (v) => v != _passwordCtrl.text
                    ? 'passwords_not_match'.tr : null,
              ),
              const SizedBox(height: 16),

              // ── Error ─────────────────────────────────
              Obx(() => _auth.errorMessage.value.isNotEmpty
                  ? Container(
                width:   double.infinity,
                margin:  const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:  AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Text(_auth.errorMessage.value,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.danger)),
              )
                  : const SizedBox.shrink()),

              const SizedBox(height: 24),

              // ── Register button ───────────────────────
              Obx(() => SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _auth.isLoading.value ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation:       0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _auth.isLoading.value
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : Text('register'.tr, style: AppTextStyles.button),
                ),
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decor({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText:   hint,
        hintStyle:  AppTextStyles.label,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled:     true,
        fillColor:  AppColors.surfaceVariant,
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
}

// ── Shared widgets ─────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController        controller;
  final String                       hint;
  final IconData                     icon;
  final TextInputType?               keyboardType;
  final String? Function(String?)?   validator;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller:   controller,
    keyboardType: keyboardType,
    validator:    validator,
    style:        AppTextStyles.bodyMd,
    decoration: InputDecoration(
      hintText:   hint,
      hintStyle:  AppTextStyles.label,
      prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
      filled:     true,
      fillColor:  AppColors.surfaceVariant,
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
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 3, height: 18,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 8),
    Text(title,
        style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary)),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: AppTextStyles.label.copyWith(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600));
}