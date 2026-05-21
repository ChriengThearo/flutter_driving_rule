import 'package:flutter/material.dart';

import '../../../data/auth/auth_repository.dart';
import '../../../data/auth/auth_result.dart';
import '../domain/auth_mode.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  String? validatePhoneNumber(String? value) {
    final phone = value?.trim() ?? '';
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (phone.isEmpty) {
      return 'Phone number is required.';
    }
    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid phone number (8-15 digits).';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? validateFullName(String? value) {
    final fullName = value?.trim() ?? '';
    if (fullName.isEmpty) {
      return 'Full name is required.';
    }
    return null;
  }

  Future<AuthResult> submit({
    required AuthMode mode,
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final result = mode == AuthMode.register
        ? await _repository.register(
            phoneNumber: phoneNumber.trim(),
            fullName: fullName.trim(),
            password: password,
          )
        : await _repository.login(
            phoneNumber: phoneNumber.trim(),
            password: password,
          );

    isLoading = false;
    if (result.isSuccess) {
      successMessage = result.message;
    } else {
      errorMessage = result.message;
    }
    notifyListeners();
    return result;
  }
}
