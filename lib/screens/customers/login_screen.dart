// ============================================================
// FILE: lib/screens/auth/login_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool  _obscure      = true;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.login(
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (ok) Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // ── Logo ─────────────────────────────────
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color:      AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset:     const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('P',
                          style: TextStyle(
                              color:      Colors.white,
                              fontSize:   38,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('welcome_back'.tr, style: AppTextStyles.h1.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text('login_subtitle'.tr,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 36),

                // ── Email ────────────────────────────────
                _FieldLabel(label: 'email'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style:        AppTextStyles.bodyMd,
                  decoration:   _inputDecor(hint: 'email_hint'.tr, icon: Icons.email_outlined),
                  validator: (v) => v == null || !GetUtils.isEmail(v)
                      ? 'valid_email_required'.tr : null,
                ),
                const SizedBox(height: 20),

                // ── Password ─────────────────────────────
                _FieldLabel(label: 'password'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  style:       AppTextStyles.bodyMd,
                  decoration:  _inputDecor(
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
                  validator: (v) => v == null || v.isEmpty ? 'password_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // ── Error message ─────────────────────────
                Obx(() => _auth.errorMessage.value.isNotEmpty
                    ? Container(
                  width:  double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:  AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_auth.errorMessage.value,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.danger)),
                    ),
                  ]),
                )
                    : const SizedBox.shrink()),

                const SizedBox(height: 24),

                // ── Login button ──────────────────────────
                Obx(() => SizedBox(
                  width:  double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _auth.isLoading.value ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _auth.isLoading.value
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : Text('login'.tr, style: AppTextStyles.button),
                  ),
                )),

                const SizedBox(height: 24),

                // ── Divider ───────────────────────────────
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or'.tr,
                        style: AppTextStyles.label.copyWith(color: AppColors.textHint)),
                  ),
                  const Expanded(child: Divider()),
                ]),

                const SizedBox(height: 24),

                // ── Register button ───────────────────────
                SizedBox(
                  width:  double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => const RegisterScreen()),
                    style: OutlinedButton.styleFrom(
                      side:  BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('create_account'.tr,
                        style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText:   hint,
        hintStyle:  AppTextStyles.label,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled:     true,
        fillColor:  AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.danger, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.danger, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: AppTextStyles.label.copyWith(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600));
}