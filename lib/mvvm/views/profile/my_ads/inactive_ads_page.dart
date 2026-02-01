import 'package:flutter/material.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';

class InactiveAdsPage extends StatelessWidget {
  const InactiveAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = List.generate(2, (i) {
      return {
        'title': i == 0 ? 'Old Apartment' : 'Closed Shop',
        'location': i == 0 ? 'Blue Area' : 'G-9 Markaz',
        'subLocation': 'Islamabad',
        'price': i == 0 ? '15000' : '12000',
        'bedrooms': i == 0 ? 2 : 1,
        'bathrooms': i == 0 ? 1 : 1,
        'images': [AppImages.img1, AppImages.img2],
      };
    });

    final categories = [
      {'label': 'Hostel', 'icon': AppImages.hostel},
      {'label': 'House', 'icon': AppImages.house},
      {'label': 'Flat', 'icon': AppImages.flat},
      {'label': 'Office', 'icon': AppImages.office},
      {'label': 'Shop', 'icon': AppImages.shop},
    ];

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
                      statusText: 'Inactive',
                      statusColor: Colors.red,
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
