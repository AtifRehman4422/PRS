import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';

class SearchCityView extends StatefulWidget {
  final String selectedCityName;
  final Function(String name, String imagePath) onCitySelected;
  const SearchCityView({
    super.key,
    required this.selectedCityName,
    required this.onCitySelected,
  });

  @override
  State<SearchCityView> createState() => _SearchCityViewState();
}

class _SearchCityViewState extends State<SearchCityView> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allCities = [
    {'name': 'Islamabad', 'image': AppImages.islamabad},
    {'name': 'Karachi', 'image': AppImages.karachi},
    {'name': 'Lahore', 'image': AppImages.lahore},
    {'name': 'Rawalpindi', 'image': ''},
    {'name': 'Multan', 'image': AppImages.multan},
    {'name': 'Faisalabad', 'image': AppImages.faisalabad},
    {'name': 'Peshawar', 'image': AppImages.peshawar},
    {'name': 'Quetta', 'image': ''},
    {'name': 'Sialkot', 'image': ''},
    {'name': 'Gujranwala', 'image': ''},
  ];

  List<Map<String, String>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = _allCities;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = _allCities
          .where((city) => city['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 32),
                  if (_searchController.text.isEmpty) ...[
                    Text(
                      'Popular Cities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _popularCity('Islamabad', AppImages.islamabad),
                          _popularCity('Karachi', AppImages.karachi),
                          _popularCity('Lahore', AppImages.lahore),
                          _popularCity('Faisalabad', AppImages.faisalabad),
                          _popularCity('Multan', AppImages.multan),
                          _popularCity('Peshawar', AppImages.peshawar),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchController.text.isEmpty
                            ? 'All Cities'
                            : 'Search Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_filteredCities.length} cities',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filteredCities.isEmpty)
                    _buildNoResults()
                  else
                    _allCitiesList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Text(
            'Search City',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2), width: 2),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintText: '', // Hint is handled by the animation
            ),
          ),
          Positioned(
            left: 48,
            top: 18,
            child: IgnorePointer(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  if (value.text.isNotEmpty) return const SizedBox.shrink();
                  return Row(
                    children: [
                      const Text(
                        'Try: ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        child: AnimatedTextKit(
                          isRepeatingAnimation: true,
                          repeatForever: true,
                          pause: const Duration(milliseconds: 1000),
                          animatedTexts: [
                            TyperAnimatedText(
                              'Islamabad',
                              speed: const Duration(milliseconds: 100),
                            ),
                            TyperAnimatedText(
                              'Karachi',
                              speed: const Duration(milliseconds: 100),
                            ),
                            TyperAnimatedText(
                              'Lahore',
                              speed: const Duration(milliseconds: 100),
                            ),
                            TyperAnimatedText(
                              'Faisalabad',
                              speed: const Duration(milliseconds: 100),
                            ),
                            TyperAnimatedText(
                              'Multan',
                              speed: const Duration(milliseconds: 100),
                            ),
                            TyperAnimatedText(
                              'Peshawar',
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _popularCity(String name, String imagePath) {
    final isSelected = widget.selectedCityName == name;
    return GestureDetector(
      onTap: () {
        widget.onCitySelected(name, imagePath);
        Navigator.pop(context);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(44),
                child: imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.location_city,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No cities found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for another city',
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _allCitiesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredCities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final city = _filteredCities[index];
        final isSelected = widget.selectedCityName == city['name'];
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.surface
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_city_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              city['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColors.primary)
                : Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            onTap: () {
              widget.onCitySelected(city['name']!, city['image']!);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
