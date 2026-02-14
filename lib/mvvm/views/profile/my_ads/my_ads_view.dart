import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'active_ads_page.dart';
import 'inactive_ads_page.dart';

class MyAdsView extends StatelessWidget {
  const MyAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: const TabBar(
                    indicatorColor: AppColors.primary,
                    labelPadding: EdgeInsets.symmetric(horizontal: 16),
                    tabs: [
                      Tab(child: Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700))),
                      Tab(child: Text('Inactive', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TabBarView(
                  children: [
                    ActiveAdsPage(),
                    InactiveAdsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.22,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeaderPainter())),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  AppImages.logo,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                FadeInSlide(
                  delay: 0.0,
                  child: Text(
                    'My Property',
                    style: TextStyle(
                      fontSize: 22,
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
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.1,
      0,
      size.height * 0.8,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
