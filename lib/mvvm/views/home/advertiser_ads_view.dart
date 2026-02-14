import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';

class AdvertiserAdsView extends StatelessWidget {
  final String advertiserName;

  const AdvertiserAdsView({super.key, required this.advertiserName});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Hostel', 'icon': AppImages.hostel},
      {'label': 'House', 'icon': AppImages.house},
      {'label': 'Flat', 'icon': AppImages.flat},
      {'label': 'Office', 'icon': AppImages.office},
      {'label': 'Shop', 'icon': AppImages.shop},
      {'label': 'Marquee', 'icon': AppImages.img1},
      {'label': 'Guest House', 'icon': AppImages.house},
      {'label': 'Farm House', 'icon': AppImages.img2},
    ];

    final ads = List.generate(4, (i) {
      return {
        'title': 'GirlsHostel',
        'location': 'Islamabad',
        'subLocation': 'Faizabad, Rawalpindi',
        'price': '3000',
        'beds': 3,
        'baths': 1,
        'image': AppImages.one,
        'time': '4 minutes',
        'active': true,
      };
    });

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          advertiserName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Ads list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return FadeInSlide(
                      delay: 0.1 + index * 0.05,
                      child: PropertyCard(
                        title: ad['title'] as String,
                        location: ad['location'] as String,
                        subLocation: ad['subLocation'] as String,
                        price: ad['price'] as String,
                        bedrooms: ad['beds'] as int,
                        bathrooms: ad['baths'] as int,
                        images: [AppImages.img1, AppImages.img2],
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


