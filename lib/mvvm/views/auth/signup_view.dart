import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/core/widgets/logo_loader.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/auth/email_verification_code_screen.dart';
import 'package:propertyrent/mvvm/views/auth/login_view.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSigningUp = false;
  String? _pickedImagePath;

  static final _onlyDigits = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) setState(() => _pickedImagePath = xFile.path);
  }

  void _showMessageDialog({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.info_outline : Icons.check_circle_outline,
              color: isError ? Colors.orange : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
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

  /// Send verification code to email; then open verification screen. No Firebase signup yet.
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImagePath == null) {
      _showMessageDialog(
        title: 'Profile image required',
        message: 'Please select a profile image from gallery.',
        isError: true,
      );
      return;
    }
    setState(() => _isSigningUp = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final emailRepo = ref.read(emailVerificationRepositoryProvider);
      // Request verification code and always open verification screen.
      // Code is sent to user's email; we no longer show it in a popup.
      await emailRepo.requestVerificationCode(email);
      if (!mounted) return;
      _openVerificationScreen(email, password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final isDuplicateEmail = e.code == 'email-already-in-use';
      _showMessageDialog(
        title: isDuplicateEmail ? 'Email already in use' : 'Error',
        message: isDuplicateEmail
            ? 'This email is already registered. Please sign in or use another email.'
            : (e.message ?? 'Failed to send code'),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessageDialog(
        title: 'Error',
        message: e.toString(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSigningUp = false);
    }
  }

  void _openVerificationScreen(String email, String password) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailVerificationCodeScreen(
          email: email,
          password: password,
        ),
      ),
    );
  }

  Widget _gradientIcon(
    IconData icon, {
    Color color1 = Colors.red,
    Color color2 = Colors.black,
    double size = 24,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [color1, color2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: size.height * 0.92,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top curved header with avatar
          Container(
            height: size.height * 0.26,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size(size.width, size.height * 0.30),
                  painter: _SignupHeaderPainter(),
                ),
                // Decorative circles
                Positioned(
                  left: -40,
                  top: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Avatar with gallery pick
                      FadeInSlide(
                        delay: 0.0,
                        child: GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: colorScheme.surface,
                                  backgroundImage: _pickedImagePath != null
                                      ? FileImage(File(_pickedImagePath!))
                                      : null,
                                  child: _pickedImagePath == null
                                      ? _gradientIcon(
                                          Icons.person_outline,
                                          size: 45,
                                          color1: Colors.grey,
                                          color2: Colors.black,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_library,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const FadeInSlide(
                        delay: 0.1,
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form content - scroll with keyboard so focused field stays visible
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // UserName Field
                    FadeInSlide(
                      delay: 0.2,
                      child: _buildInputField(
                        context,
                        controller: _nameController,
                        hint: 'Username',
                        icon: Icons.person_outline,
                        iconColor1: Colors.grey,
                        iconColor2: Colors.black,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Name required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    FadeInSlide(
                      delay: 0.3,
                      child: _buildInputField(
                        context,
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline,
                        iconColor1: AppColors.primary,
                        iconColor2: Colors.red.shade800,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field
                    FadeInSlide(
                      delay: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                 
                                  const Text(
                                    '🇵🇰',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+92',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [_onlyDigits],
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: '3*********',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (v) {
                                  final s = (v ?? '').trim();
                                  if (s.length != 10) return 'Enter 10-digit number';
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(s)) return 'Only digits';
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                '${_phoneController.text.length}/10',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    FadeInSlide(
                      delay: 0.5,
                      child: _buildInputField(
                        context,
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        iconColor1: Colors.grey,
                        iconColor2: Colors.black,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: _gradientIcon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color1: AppColors.primary,
                            color2: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password required';
                          if (value.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    FadeInSlide(
                      delay: 0.55,
                      child: _buildInputField(
                        context,
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        iconColor1: Colors.grey,
                        iconColor2: Colors.black,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: _gradientIcon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color1: AppColors.primary,
                            color2: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Confirm password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign Up (email + password)
                    FadeInSlide(
                      delay: 0.6,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSigningUp ? null : _signUpWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: _isSigningUp
                              ? const LogoLoader(size: 28)
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms and conditions
                    FadeInSlide(
                      delay: 0.7,
                      child: Text(
                        'By signing up, you agree to our Terms of Service\nand Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    FadeInSlide(
                      delay: 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const LoginView(),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor1,
    required Color iconColor2,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: _gradientIcon(icon, color1: iconColor1, color2: iconColor2),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}

// Custom painter for signup header
class _SignupHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.15,
      0,
      size.height * 0.75,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
