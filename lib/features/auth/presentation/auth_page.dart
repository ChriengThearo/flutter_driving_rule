import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/auth/auth_repository.dart';
import '../domain/auth_mode.dart';
import 'auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, AuthRepository? repository})
    : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthController _authController;
  AuthMode _mode = AuthMode.register;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      widget._repository ?? MysqlAuthRepository(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) {
      return;
    }
    setState(() {
      _mode = mode;
    });
    _formKey.currentState?.reset();
    _authController.clearMessages();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (_mode == AuthMode.register &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm password does not match.')),
      );
      return;
    }

    final result = await _authController.submit(
      mode: _mode,
      phoneNumber: _phoneController.text,
      fullName: _fullNameController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess && _mode == AuthMode.register) {
      _confirmPasswordController.clear();
      _passwordController.clear();
      _fullNameController.clear();
      _phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _authController,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderCard(),
                      const SizedBox(height: 22),
                      _AuthToggle(selectedMode: _mode, onChanged: _switchMode),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: _authController.validatePhoneNumber,
                            ),
                            const SizedBox(height: 14),
                            if (_mode == AuthMode.register) ...[
                              TextFormField(
                                controller: _fullNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: _authController.validateFullName,
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: _authController.validatePassword,
                            ),
                            if (_mode == AuthMode.register) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                ),
                                validator: _authController.validatePassword,
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (_authController.errorMessage != null)
                              _StatusBanner(
                                text: _authController.errorMessage!,
                                backgroundColor: AppColors.danger.withValues(
                                  alpha: 0.12,
                                ),
                                textColor: AppColors.danger,
                              ),
                            if (_authController.successMessage != null)
                              _StatusBanner(
                                text: _authController.successMessage!,
                                backgroundColor: AppColors.accent.withValues(
                                  alpha: 0.12,
                                ),
                                textColor: AppColors.primary,
                              ),
                            if (_authController.errorMessage != null ||
                                _authController.successMessage != null)
                              const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _authController.isLoading
                                  ? null
                                  : _submit,
                              child: _authController.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Text(
                                      _mode == AuthMode.register
                                          ? 'Create Account'
                                          : 'Login',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120D3B66),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'images/login_register/hands.png',
              width: 98,
              height: 98,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 98,
                height: 98,
                color: AppColors.background,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driving Rule',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'WELCOME!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthToggle extends StatelessWidget {
  const _AuthToggle({required this.selectedMode, required this.onChanged});

  final AuthMode selectedMode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Register',
              isSelected: selectedMode == AuthMode.register,
              onTap: () => onChanged(AuthMode.register),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Login',
              isSelected: selectedMode == AuthMode.login,
              onTap: () => onChanged(AuthMode.login),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
