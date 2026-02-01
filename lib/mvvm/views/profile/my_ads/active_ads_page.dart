import 'package:flutter/material.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';

class ActiveAdsPage extends StatelessWidget {
  const ActiveAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Hostel', 'icon': AppImages.hostel},
      {'label': 'House', 'icon': AppImages.house},
      {'label': 'Flat', 'icon': AppImages.flat},
      {'label': 'Office', 'icon': AppImages.office},
      {'label': 'Shop', 'icon': AppImages.shop},
    ];
    final ads = List.generate(3, (i) {
      final type = i == 0 ? 'Hostel' : (i == 1 ? 'House' : 'Flat');
      final images = type == 'Hostel'
          ? [AppImages.hostel, AppImages.img2]
          : (type == 'House'
              ? [AppImages.house, AppImages.img2]
              : [AppImages.flat, AppImages.img2]);
      return {
        'title': i == 0 ? 'Malik Hostel' : (i == 1 ? 'Rajpoot House' : 'Luxury Flat'),
        'location': i == 0 ? 'Faizabad, Rawalpindi' : (i == 1 ? 'PWD Housing Society' : 'DHA Phase 2'),
        'subLocation': 'Islamabad',
        'price': i == 0 ? '3000' : (i == 1 ? '30000' : '85000'),
        'bedrooms': i == 0 ? 3 : (i == 1 ? 4 : 5),
        'bathrooms': i == 0 ? 1 : (i == 1 ? 3 : 6),
        'images': images,
      };
    });

    return Stack(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _CategoryChip(label: c['label']!, iconPath: c['icon']!),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
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
                      bedrooms: ad['bedrooms'] as int,
                      bathrooms: ad['bathrooms'] as int,
                      images: ad['images'] as List<String>,
                      isOwner: true,
                      showBadges: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String iconPath;
  const _CategoryChip({required this.label, required this.iconPath});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
