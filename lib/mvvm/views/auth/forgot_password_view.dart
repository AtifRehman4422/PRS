import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/mvvm/views/auth/login_view.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  void _goToLogin() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: size.height * 0.78,
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
          // Top curved header
          Container(
            height: size.height * 0.18,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size.width, size.height * 0.18),
                  painter: _ForgotPasswordHeaderPainter(),
                ),
                // Decorative circles
                Positioned(
                  right: -30,
                  top: -30,
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
                  left: -20,
                  top: 60,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                // Back button - Opens Login Page
                Positioned(
                  left: 16,
                  top: 16,
                  child: GestureDetector(
                    onTap: _goToLogin,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Drag handle and logo
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(AppImages.logo, height: 50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Lock icon
                    FadeInSlide(
                      delay: 0.0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: _gradientIcon(Icons.lock_reset, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    FadeInSlide(
                      delay: 0.1,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    FadeInSlide(
                      delay: 0.2,
                      child: Text(
                        'Don\'t worry! It happens. Please enter your\nemail address to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Email Field
                    FadeInSlide(
                      delay: 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _gradientIcon(
                                Icons.mail_outline,
                                color1: AppColors.primary,
                                color2: Colors.red.shade800,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Send Email Button
                    FadeInSlide(
                      delay: 0.4,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Handle forgot password
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Password reset email sent!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              // Go to login after sending email
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  _goToLogin();
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Send Email',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Back to Login Link
                    FadeInSlide(
                      delay: 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember password?',
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          TextButton(
                            onPressed: _goToLogin,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for forgot password header
class _ForgotPasswordHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.2,
      0,
      size.height * 0.7,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
