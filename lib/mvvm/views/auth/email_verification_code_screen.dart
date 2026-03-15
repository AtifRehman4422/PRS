import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/widgets/logo_loader.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';
import 'package:propertyrent/data/datasource/auth_api.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';

/// Email verification code screen. User enters 6-digit code sent by backend after signup.
/// On success, backend creates account and returns JWT; we store token and navigate back.
class EmailVerificationCodeScreen extends ConsumerStatefulWidget {
  const EmailVerificationCodeScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<EmailVerificationCodeScreen> createState() =>
      _EmailVerificationCodeScreenState();
}

class _EmailVerificationCodeScreenState
    extends ConsumerState<EmailVerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;
  bool _didShowSentMessage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didShowSentMessage && mounted) {
        _didShowSentMessage = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent to ${widget.email}. Check your inbox and Spam folder.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text.trim()).join();

  Future<void> _verify() async {
    if (_enteredCode.length != 6) return;
    setState(() => _isVerifying = true);
    try {
      final result = await AuthApi.verifyOtp(widget.email, _enteredCode);
      if (!mounted) return;
      if (!result.success || result.token == null) {
        setState(() => _isVerifying = false);
        _showDialog('Invalid or expired code', result.message ?? 'Please check the code and try again.', isError: true);
        return;
      }
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.setTokenAndEmitUser(result.token!);
      if (!mounted) return;
      _showDialog(
        'Account created',
        'You are signed in. Welcome!',
        isError: false,
        onOk: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showDialog('Error', e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    _showDialog(
      'Resend code',
      'To get a new code, go back and submit signup again. The previous code is valid for 5 minutes.',
      isError: false,
    );
    if (mounted) setState(() => _isResending = false);
  }

  void _showDialog(String title, String message, {required bool isError, VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onOk?.call();
            },
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit code to the email you entered:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => _buildDigitField(i, colorScheme)),
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Verify & Create account',
                  onPressed: _isVerifying || _enteredCode.length != 6 ? null : _verify,
                  isLoading: _isVerifying,
                  loader: const LogoLoader(size: 22),
                  height: 56,
                  borderRadius: 28,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _isResending ? null : _resend,
                  icon: _isResending
                      ? const SizedBox(width: 18, height: 18, child: LogoLoader(size: 18))
                      : const Icon(Icons.refresh, color: Colors.white, size: 20),
                  label: Text(
                    _isResending ? 'Sending…' : 'Resend code',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildDigitField(int index, ColorScheme colorScheme) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          if (v.length == 1) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
            setState(() {});
          }
        },
      ),
    );
  }
}
