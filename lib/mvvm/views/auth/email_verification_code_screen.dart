import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/widgets/logo_loader.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';

/// Email verification code screen. User enters 6-digit code sent to email.
/// On success, registers on Firebase and navigates to login.
class EmailVerificationCodeScreen extends ConsumerStatefulWidget {
  const EmailVerificationCodeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

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
  String? _devCode;

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
      final repo = ref.read(emailVerificationRepositoryProvider);
      final valid = await repo.verifyCode(widget.email, _enteredCode);
      if (!mounted) return;
      if (!valid) {
        setState(() => _isVerifying = false);
        _showDialog('Invalid code', 'Please check the code and try again.', isError: true);
        return;
      }
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signUpWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      await authRepo.signOut();
      if (!mounted) return;
      ref.invalidate(authStateProvider);
      _showDialog(
        'Account created',
        'You can now sign in with your email and password.',
        isError: false,
        onOk: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final isDuplicate = e.code == 'email-already-in-use';
      _showDialog(
        isDuplicate ? 'Email already in use' : 'Error',
        isDuplicate
            ? 'This email is already registered. Please sign in.'
            : (e.message ?? e.code),
        isError: true,
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
    try {
      final repo = ref.read(emailVerificationRepositoryProvider);
      final devCode = await repo.requestVerificationCode(widget.email);
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _devCode = devCode;
      });
      if (devCode != null) {
        _showDialog('Code (for testing)', 'Your code: $devCode', isError: false);
      } else {
        _showDialog('Code sent', 'Check your email for the new code.', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      _showDialog('Resend failed', e.toString(), isError: true);
    }
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isVerifying || _enteredCode.length != 6
                        ? null
                        : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child: _isVerifying
                        ? const LogoLoader(size: 28)
                        : const Text('Verify & Create account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
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
                if (_devCode != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Test code: $_devCode',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
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
