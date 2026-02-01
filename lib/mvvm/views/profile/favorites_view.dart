import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Hostel', 'icon': AppImages.hostel},
      {'label': 'House', 'icon': AppImages.house},
      {'label': 'Flat', 'icon': AppImages.flat},
      {'label': 'Office', 'icon': AppImages.office},
      {'label': 'Shop', 'icon': AppImages.shop},
    ];

    final favorites = List.generate(3, (i) {
      return {
        'title': i == 0 ? 'Luxury Villa' : (i == 1 ? 'Modern Apartment' : 'Cozy Studio'),
        'location': 'Islamabad',
        'subLocation': 'DHA Phase 2',
        'price': i == 0 ? '85000' : (i == 1 ? '45000' : '25000'),
        'bedrooms': i == 0 ? 5 : (i == 1 ? 3 : 1),
        'bathrooms': i == 0 ? 6 : (i == 1 ? 2 : 1),
        'images': const [AppImages.img1, AppImages.img2],
      };
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Logo
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
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _CategoryChip(label: c['label']!, iconPath: c['icon']!),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),

              // Favorites List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final ad = favorites[index];
                    return FadeInSlide(
                      delay: 0.1 + index * 0.05,
                      child: PropertyCard(
                        title: ad['title'] as String,
                        location: ad['location'] as String,
                        subLocation: ad['subLocation'] as String,
                        price: ad['price'] as String,
                        bedrooms: ad['bedrooms'] as int,
                        bathrooms: ad['bathrooms'] as int,
                        images: ad['images'] as List<String>,
                        isFavorite: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String iconPath;

  const _CategoryChip({required this.label, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
