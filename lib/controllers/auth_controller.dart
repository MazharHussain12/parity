// ============================================================
// FILE: lib/controllers/auth_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appNew_models.dart';
import '../models/app_models.dart';

class AuthController extends GetxController {
  final Rx<BusinessUser?> currentUser = Rx<BusinessUser?>(null);
  final RxBool isLoggedIn   = false.obs;
  final RxBool isLoading    = false.obs;

  // Form observables
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved  = prefs.getString('business_id');
    if (saved != null && saved.isNotEmpty) {
      // In production: fetch from local DB / Hive / server
      // For now restore minimal session
      currentUser.value = BusinessUser(
        id:           saved,
        businessName: prefs.getString('business_name') ?? '',
        ownerName:    prefs.getString('owner_name')    ?? '',
        email:        prefs.getString('email')         ?? '',
        phone:        prefs.getString('phone')         ?? '',
        logoPath:     prefs.getString('logo_path'),
        createdAt:    DateTime.now(),
      );
      isLoggedIn.value = true;
    }
  }

  Future<bool> register({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  }) async {
    errorMessage.value = '';
    if (businessName.trim().isEmpty) {
      errorMessage.value = 'business_name_required'.tr;
      return false;
    }
    if (email.trim().isEmpty || !GetUtils.isEmail(email)) {
      errorMessage.value = 'valid_email_required'.tr;
      return false;
    }
    if (password.length < 6) {
      errorMessage.value = 'password_min_6'.tr;
      return false;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final user = BusinessUser(
      id:           DateTime.now().millisecondsSinceEpoch.toString(),
      businessName: businessName.trim(),
      ownerName:    ownerName.trim(),
      email:        email.trim().toLowerCase(),
      phone:        phone.trim(),
      createdAt:    DateTime.now(),
    );

    await _saveSession(user);
    currentUser.value = user;
    isLoggedIn.value  = true;
    isLoading.value   = false;
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    errorMessage.value = '';
    if (email.trim().isEmpty || !GetUtils.isEmail(email)) {
      errorMessage.value = 'valid_email_required'.tr;
      return false;
    }
    if (password.isEmpty) {
      errorMessage.value = 'password_required'.tr;
      return false;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    // In production: verify against DB
    // For demo: accept any stored credentials
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email') ?? '';

    if (storedEmail.isEmpty) {
      errorMessage.value = 'no_account_found'.tr;
      isLoading.value    = false;
      return false;
    }

    if (storedEmail != email.trim().toLowerCase()) {
      errorMessage.value = 'invalid_credentials'.tr;
      isLoading.value    = false;
      return false;
    }

    await _checkSession();
    isLoading.value = false;
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUser.value = null;
    isLoggedIn.value  = false;
    Get.offAllNamed('/login');
  }

  Future<void> _saveSession(BusinessUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_id',   user.id);
    await prefs.setString('business_name', user.businessName);
    await prefs.setString('owner_name',    user.ownerName);
    await prefs.setString('email',         user.email);
    await prefs.setString('phone',         user.phone);
    if (user.logoPath != null) {
      await prefs.setString('logo_path', user.logoPath!);
    }
  }
}