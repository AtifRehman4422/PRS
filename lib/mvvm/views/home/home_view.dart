import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/home/category_listing_view.dart';
import 'package:propertyrent/mvvm/views/home/search_city_view.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeView extends ConsumerStatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeView({super.key, this.onProfileTap});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String _selectedCityName = 'Islamabad';
  String _selectedCityImage = AppImages.islamabad;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallHeight = size.height < 700;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, size, widget.onProfileTap, user),
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
    AuthUser? user,
  ) {
    final headerHeight = size.height * 0.28;
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
                opacity: 0.60,
                child: Image.asset(AppImages.home, fit: BoxFit.cover),
              ),
            ),
          ),
          // Decorative circles removed as requested
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
                      // Logo and Brand
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            // decoration: BoxDecoration(
                            //   color: const Color.fromARGB(255, 57, 24, 24),
                            //   borderRadius: BorderRadius.circular(12),
                            // ),
                            child: Image.asset(AppImages.logo, height: 40 , color: Colors.white,),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 150,
                            child: AnimatedTextKit(
                              animatedTexts: [
                                WavyAnimatedText(
                                  'PropertyRent',
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    // letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                              repeatForever: true,
                            ),
                          ),
                        ],
                      ),
                      // User name + avatar (when logged in) or Login button
                      GestureDetector(
                        onTap: onProfileTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user != null ? user.displayLabel : 'Login',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                backgroundImage: user != null && user.hasPhoto
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user == null || !user.hasPhoto
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xFFFF5252),
                                        size: 18,
                                      )
                                    : null,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    height: searchHeight.clamp(52, 62),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                          child: Container(
                            key: ValueKey(_selectedCityImage),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _selectedCityImage.isNotEmpty
                                  ? Image.asset(
                                      _selectedCityImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Icon(
                                        Icons.location_city,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                _selectedCityName,
                                textStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                              TyperAnimatedText(
                                'Search for Houses...',
                                textStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TyperAnimatedText(
                                'Find a Flat...',
                                textStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TyperAnimatedText(
                                'Marquee & More...',
                                textStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            repeatForever: true,
                            pause: const Duration(seconds: 2),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SearchCityView(
                                selectedCityName: _selectedCityName,
                                onCitySelected: (name, image) {
                                  setState(() {
                                    _selectedCityName = name;
                                    _selectedCityImage = image;
                                  });
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
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
    return const SizedBox.shrink();
  }

  Widget _buildCategoryGrid(Size size) {
    final items = [
      _CategoryItem(title: 'Hostel', imagePath: AppImages.hostel),
      _CategoryItem(title: 'Flat', imagePath: AppImages.flat),
      _CategoryItem(title: 'Office', imagePath: AppImages.office),
      _CategoryItem(title: 'Shop', imagePath: AppImages.shop),
      _CategoryItem(title: 'Marquee', imagePath: AppImages.img1),
      _CategoryItem(title: 'Farmhouse', imagePath: AppImages.img2),
      _CategoryItem(title: 'House', imagePath: AppImages.house),
      _CategoryItem(title: 'Guest House', imagePath: AppImages.house),
    ];

    final crossAxisCount = size.width < 360 ? 1 : 2;
    // Increased aspect ratio to fit the button below the card
    final aspectRatio = size.height < 700 ? 0.78 : 0.75;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 30,
              crossAxisSpacing: 24,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // The Card (Image/Icon)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: item.title == 'Shop'
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.surface,
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.storefront_rounded,
                                size: 70,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          )
                        : Theme.of(context).brightness == Brightness.dark
                            ? ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(item.imagePath, fit: BoxFit.cover),
                              )
                            : Image.asset(item.imagePath, fit: BoxFit.cover),
                  ),
                  // Gradient overlay (Red Shade at bottom)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // The Red Button below the card
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for curved header
class _HomeHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE30707), // Vibrant red
          Color(0xFFFF5722), // Vibrant orange/coral
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.78);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 1.15,
      0,
      size.height * 0.84,
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
    path.lineTo(size.width, size.height * 0.78);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.10,
      0,
      size.height * 0.83,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
