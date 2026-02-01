import 'package:flutter/material.dart';
import 'package:propertyrent/mvvm/views/home/category_listing_view.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';

class HomeView extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeView({super.key, this.onProfileTap});

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
    final isSmallHeight = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, size, onProfileTap),
            SizedBox(height: isSmallHeight ? 12 : 16),
            _buildTitle(size),
            SizedBox(height: isSmallHeight ? 12 : 16),
            Expanded(
              child: SingleChildScrollView(child: _buildCategoryGrid(size)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Size size,
    VoidCallback? onProfileTap,
  ) {
    final headerHeight = size.height * 0.26;
    final searchHeight = size.height * 0.06;

    return Container(
      height: headerHeight,
      child: Stack(
        children: [
          // Curved background
          Positioned.fill(child: CustomPaint(painter: _HomeHeaderPainter())),
          // Background image overlay
          Positioned.fill(
            child: ClipPath(
              clipper: _HomeHeaderClipper(),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(AppImages.home, fit: BoxFit.cover),
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, size.height * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(
                  delay: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Welcome text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Find Your Place',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Login button
                      GestureDetector(
                        onTap: onProfileTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: _gradientIcon(Icons.person, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                // Search bar
                FadeInSlide(
                  delay: 0.1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    height: searchHeight.clamp(48, 58),
                    child: Row(
                      children: [
                        _gradientIcon(
                          Icons.location_on,
                          color1: AppColors.primary,
                          color2: Colors.red.shade300,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Islamabad',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(Size size) {
    final logoHeight = size.height * 0.07;
    final titleFontSize = size.width * 0.06;

    return FadeInSlide(
      delay: 0.2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 3,
              ),
            ),
            child: Image.asset(
              AppImages.logo,
              height: logoHeight.clamp(40, 60),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'PropertyRent',
                textStyle: TextStyle(
                  fontSize: titleFontSize.clamp(22, 30),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
                speed: const Duration(milliseconds: 200),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(Size size) {
    final items = [
      _CategoryItem(title: 'Hostel', imagePath: AppImages.hostel),
      _CategoryItem(title: 'House', imagePath: AppImages.house),
      _CategoryItem(title: 'Flat', imagePath: AppImages.flat),
      _CategoryItem(title: 'Office', imagePath: AppImages.office),
      _CategoryItem(title: 'Shop', imagePath: AppImages.shop),
    ];

    final crossAxisCount = size.width < 360 ? 1 : 2;
    final aspectRatio = size.height < 700 ? 1.0 : 0.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return FadeInSlide(
                delay: 0.3 + (index * 0.1),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryListingView(categoryName: item.title),
                      ),
                    );
                  },
                  child: _CategoryCard(item: item, index: index),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

class _CategoryItem {
  final String title;
  final String imagePath;

  const _CategoryItem({required this.title, required this.imagePath});
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final int index;

  const _CategoryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(item.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for curved header
class _HomeHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.15,
      0,
      size.height * 0.85,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom clipper for header
class _HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.15,
      0,
      size.height * 0.85,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
