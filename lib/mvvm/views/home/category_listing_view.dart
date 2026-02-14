import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/mvvm/views/home/property_detail_view.dart';

class CategoryListingView extends StatefulWidget {
  final String categoryName;

  const CategoryListingView({super.key, required this.categoryName});

  @override
  State<CategoryListingView> createState() => _CategoryListingViewState();
}

class _CategoryListingViewState extends State<CategoryListingView> {
  // Dummy data with multiple images
  final List<Map<String, dynamic>> _properties = [
    {
      'title': 'Luxury House',
      'location': 'Islamabad',
      'subLocation': 'Sector F-7',
      'price': '350000',
      'bedrooms': 5,
      'bathrooms': 6,
      'images': [AppImages.img1, AppImages.img2],
    },
    {
      'title': 'Modern Villa',
      'location': 'Lahore',
      'subLocation': 'DHA Phase 6',
      'price': '150000',
      'bedrooms': 6,
      'bathrooms': 7,
      'images': [AppImages.img1, AppImages.img2],
    },
    {
      'title': 'Seaview Apartment',
      'location': 'Karachi',
      'subLocation': 'Clifton Block 4',
      'price': '85000',
      'bedrooms': 3,
      'bathrooms': 3,
      'images': [AppImages.img1, AppImages.img2],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Logo Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, // Increased visibility
              child: Center(
                child: Image.asset(
                  AppImages.logo,
                  width: 500, // Increased size
                  height: 500,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              FadeInSlide(delay: 0.1, child: _buildFilterBar(context)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _properties.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _properties.length) {
                      final prop = _properties[index];
                      return FadeInSlide(
                        delay: 0.2 + (index * 0.15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    PropertyDetailView(property: prop),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeOutQuart;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: PropertyCard(
                            title: prop['title'],
                            location: prop['location'],
                            subLocation: prop['subLocation'],
                            price: prop['price'],
                            bedrooms: prop['bedrooms'],
                            bathrooms: prop['bathrooms'],
                            images: (prop['images'] as List?)?.map((e) => e.toString()).toList() ?? [AppImages.home],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterButton(
            context,
            'Sort',
            Icons.sort,
            () => _showSortBottomSheet(context),
            isPrimary: true,
          ),
          const SizedBox(width: 10),
          _buildFilterButton(
            context,
            'City',
            Icons.location_city,
            () => _showCityBottomSheet(context),
            isPrimary: true,
          ),
          const SizedBox(width: 10),
          _buildFilterButton(context, 'Map', Icons.map_outlined, () {}, isPrimary: true),
          const SizedBox(width: 10),
          _buildFilterButton(
            context,
            'Price Range',
            Icons.tune,
            () => _showPriceRangeBottomSheet(context),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: isPrimary ? null : Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.white : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sort By',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),
              _buildSortOption(context, Icons.local_fire_department, 'Popular', true),
              _buildSortOption(context, Icons.new_releases, 'Newest', false),
              _buildSortOption(context, Icons.arrow_upward, 'Price: Low to High', false),
              _buildSortOption(
                context,
                Icons.arrow_downward,
                'Price: High to Low',
                false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, IconData icon, String text, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {},
    );
  }

  void _showCityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select City',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  // Premium Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Popular Cities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPopularCityItem(Icons.location_city, 'Islamabad'),
                        _buildPopularCityItem(Icons.apartment, 'Lahore'),
                        _buildPopularCityItem(Icons.business, 'Karachi'),
                        _buildPopularCityItem(Icons.landscape, 'Murree'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'All Cities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller:
                          controller, // Essential for DraggableScrollableSheet
                      children: const [
                        ListTile(title: Text('Abbottabad')),
                        ListTile(title: Text('Bahawalpur')),
                        ListTile(title: Text('Faisalabad')),
                        ListTile(title: Text('Gujranwala')),
                        ListTile(title: Text('Hyderabad')),
                        ListTile(title: Text('Multan')),
                        ListTile(title: Text('Peshawar')),
                        ListTile(title: Text('Quetta')),
                        ListTile(title: Text('Rawalpindi')),
                        ListTile(title: Text('Sialkot')),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopularCityItem(IconData icon, String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showPriceRangeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // For keyboard input
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Price Range',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Min Price',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0',
                              prefixText: 'Rs. ',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Max Price',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Any',
                              prefixText: 'Rs. ',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
