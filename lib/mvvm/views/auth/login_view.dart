import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/mvvm/views/auth/signup_view.dart';
import 'package:propertyrent/mvvm/views/auth/forgot_password_view.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: size.height * 0.88,
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
            height: size.height * 0.15,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size.width, size.height * 0.15),
                  painter: _LoginHeaderPainter(),
                ),
                // Decorative circle
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
                        padding: const EdgeInsets.all(10),
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
                    const SizedBox(height: 16),
                    // Title
                    FadeInSlide(
                      delay: 0.0,
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInSlide(
                      delay: 0.1,
                      child: Text(
                        'Login to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    FadeInSlide(
                      delay: 0.2,
                      child: _buildInputField(
                        context,
                        controller: _emailController,
                        hint: 'Enter Email',
                        icon: Icons.mail_outline,
                        iconColor1: AppColors.primary,
                        iconColor2: Colors.red.shade800,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Email required' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    FadeInSlide(
                      delay: 0.3,
                      child: _buildInputField(
                        context,
                        controller: _passwordController,
                        hint: 'Enter Password',
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
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Password required' : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Forget Password
                    FadeInSlide(
                      delay: 0.4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const ForgotPasswordView(),
                            );
                          },
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    FadeInSlide(
                      delay: 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Handle login
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
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Or continue with
                    FadeInSlide(
                      delay: 0.6,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.grey.shade300,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Google Button
                    FadeInSlide(
                      delay: 0.7,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle Google sign in
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Colors.red,
                                        Colors.orange,
                                        Colors.green,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Link
                    FadeInSlide(
                      delay: 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const SignupView(),
                              );
                            },
                            child: const Text(
                              'SignUp',
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

// Custom painter for login header
class _LoginHeaderPainter extends CustomPainter {
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
