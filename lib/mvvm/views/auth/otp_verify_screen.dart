import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';
import 'package:propertyrent/core/widgets/logo_loader.dart';

/// Legacy phone OTP screen. Phone auth was removed; use email signup or Google login.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone OTP is not used. Use email signup or Google login.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Verify OTP',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.sms_outlined,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  'Code sent to ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.length != 6) return 'Enter 6-digit OTP';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Verify OTP',
                  onPressed: _isVerifying ? null : _verifyOtp,
                  isLoading: _isVerifying,
                  loader: const LogoLoader(size: 22),
                  height: 56,
                  borderRadius: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
