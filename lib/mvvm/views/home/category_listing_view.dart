import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/data/datasource/favorites_api.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/mvvm/views/add/nearby_listings_map_view.dart';
import 'package:propertyrent/mvvm/views/home/listing_feature_chips.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';
import 'package:propertyrent/mvvm/views/home/property_detail_view.dart';
import 'package:propertyrent/mvvm/views/home/search_city_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CategoryListingView extends ConsumerStatefulWidget {
  final String categoryName;
  final String city;

  const CategoryListingView({super.key, required this.categoryName, this.city = ''});

  @override
  ConsumerState<CategoryListingView> createState() => _CategoryListingViewState();
}

enum _SortOption { popular, newest, priceLowToHigh, priceHighToLow }

class _CategoryListingViewState extends ConsumerState<CategoryListingView> {
  List<ListingModel> _allListings = [];
  List<ListingModel> _listings = [];
  Set<int> _favoriteIds = {};
  bool _loading = true;
  _SortOption _sortBy = _SortOption.newest;
  double? _priceMin;
  double? _priceMax;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String _selectedCityName = '';
  String _selectedCityForApi = '';
  String _selectedHostelTypeFilter = 'Any';

  static String _propertyTypeFromCategory(String name) {
    if (name == 'Farmhouse') return 'Farm House';
    return name;
  }

  @override
  void initState() {
    super.initState();
    _selectedCityName = widget.city;
    _selectedCityForApi = widget.city;
    _load();
  }

  @override
  void didUpdateWidget(CategoryListingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      _selectedCityName = widget.city;
      _selectedCityForApi = widget.city;
      _load();
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final propertyType = _propertyTypeFromCategory(widget.categoryName);
    final city = _selectedCityForApi.isNotEmpty ? _selectedCityForApi : null;
    final list = await ListingApi.getListings(city: city, propertyType: propertyType);
    Set<int> favIds = {};
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token != null && token.isNotEmpty) {
      final favList = await FavoritesApi.list(token);
      favIds = favList.map((e) => (e['id'] as num?)?.toInt() ?? 0).where((id) => id > 0).toSet();
    }
    if (!mounted) return;
    setState(() {
      _allListings = list.map((e) => ListingModel.fromJson(e)).toList();
      _favoriteIds = favIds;
      _loading = false;
      _updateDisplayList();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _selectedCityName = '';
      _selectedCityForApi = '';
      _priceMin = null;
      _priceMax = null;
      _sortBy = _SortOption.newest;
    });
    await _load();
  }

  void _updateDisplayList() {
    var list = _allListings.where((l) {
      final r = l.rent ?? 0;
      if (_priceMin != null && r < _priceMin!) return false;
      if (_priceMax != null && r > _priceMax!) return false;
      // Hostel type filter (only when viewing Hostel category)
      if (_propertyTypeFromCategory(widget.categoryName) == 'Hostel' &&
          _selectedHostelTypeFilter != 'Any') {
        final td = l.typeDetails;
        final hostelType = (td?['hostel_type'] ?? '').toString();
        if (hostelType.isEmpty) return false;
        if (!hostelType.toLowerCase().contains(_selectedHostelTypeFilter.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
    switch (_sortBy) {
      case _SortOption.popular:
      case _SortOption.newest:
        list.sort((a, b) => _compareCreatedAt(b, a));
        break;
      case _SortOption.priceLowToHigh:
        list.sort((a, b) => (a.rent ?? 0).compareTo(b.rent ?? 0));
        break;
      case _SortOption.priceHighToLow:
        list.sort((a, b) => (b.rent ?? 0).compareTo(a.rent ?? 0));
        break;
    }
    _listings = list;
  }

  int _compareCreatedAt(ListingModel a, ListingModel b) {
    final at = a.createdAt;
    final bt = b.createdAt;
    if (at == null || at.isEmpty) return bt == null || bt.isEmpty ? 0 : 1;
    if (bt == null || bt.isEmpty) return -1;
    return at.compareTo(bt);
  }

  Future<void> _toggleFavorite(BuildContext context, int listingId) async {
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null || token.isEmpty) return;
    final isFav = _favoriteIds.contains(listingId);
    final ok = isFav ? await FavoritesApi.remove(token, listingId) : await FavoritesApi.add(token, listingId);
    if (!mounted || !ok) return;
    setState(() {
      if (isFav) {
        _favoriteIds.remove(listingId);
      } else {
        _favoriteIds.add(listingId);
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
        content: Text(isFav ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isFav ? AppColors.primary : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: _listings.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 160),
                                  Center(
                                    child: Text(
                                      'No listings yet',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 400),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                                itemCount: _listings.length,
                                itemBuilder: (context, index) {
                                  final listing = _listings[index];
                                  final images = listing.imageUrls;
                                  return FadeInSlide(
                                    delay: 0.2 + (index * 0.05),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                PropertyDetailView(listingId: listing.id),
                                            transitionsBuilder:
                                                (context, animation, secondaryAnimation, child) {
                                              const begin = Offset(0.0, 1.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeOutQuart;
                                              var tween =
                                                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                              var offsetAnimation = animation.drive(tween);
                                              return SlideTransition(position: offsetAnimation, child: child);
                                            },
                                            transitionDuration: const Duration(milliseconds: 500),
                                          ),
                                        ).then((_) => _load());
                                      },
                                      child: PropertyCard(
                                            title: listing.title,
                                            location: listing.location,
                                            subLocation: listing.subLocation,
                                            addressLine: listing.address ?? listing.sector ?? listing.landmark,
                                            cityDisplay: listing.location,
                                        topFeatureChips: buildThreeFeatureChips(context, listing),
                                            price: listing.price,
                                            bedrooms: listing.bedrooms,
                                            bathrooms: listing.bathrooms,
                                            images: images.isEmpty ? [AppImages.home] : images,
                                            isFavorite: _favoriteIds.contains(listing.id),
                                            onFavoriteTap: () => _toggleFavorite(context, listing.id),
                                            statusColor: Colors.green,
                                            showFeaturesRow: false,
                                            createdAt: listing.createdAt,
                                            onCallTap: () => _launchDialer(listing.contactPhone),
                                            onWhatsAppTap:
                                                () => _launchWhatsApp(listing.whatsapp ?? listing.contactPhone),
                                          ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchDialer(String? phone) async {
    final p = phone?.trim();
    if (p == null || p.isEmpty) return;
    final uri = 'tel:$p';
    if (await canLaunchUrlString(uri)) {
      await launchUrlString(uri);
    }
  }

  Future<void> _launchWhatsApp(String? phone) async {
    final p = phone?.replaceAll(RegExp(r'\s+'), '');
    if (p == null || p.isEmpty) return;
    final uri = 'https://wa.me/$p';
    if (await canLaunchUrlString(uri)) {
      await launchUrlString(uri);
    }
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
          if (_propertyTypeFromCategory(widget.categoryName) == 'Hostel')
            _buildFilterButton(
              context,
              _selectedHostelTypeFilter == 'Any'
                  ? 'Hostel Type'
                  : 'Hostel: $_selectedHostelTypeFilter',
              Icons.wc,
              () => _showHostelTypeBottomSheet(context),
              isPrimary: false,
              pillGradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primary],
              ),
            ),
          if (_propertyTypeFromCategory(widget.categoryName) == 'Hostel')
            const SizedBox(width: 10),
          _buildFilterButton(
            context,
            'Map',
            Icons.map_outlined,
            () {
              final propertyType = _propertyTypeFromCategory(widget.categoryName);
              final city = _selectedCityForApi.isNotEmpty ? _selectedCityForApi : null;
              NearbyListingsMapView.open(
                context,
                city: city,
                propertyType: propertyType,
              );
            },
            isPrimary: true,
            pillGradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary,
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterButton(
            context,
            'Price Range',
            Icons.tune,
            () => _showPriceRangeBottomSheet(context),
            isPrimary: true,
            pillGradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary,
              ],
            ),
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
    LinearGradient? pillGradient,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: pillGradient,
          color: pillGradient == null
              ? (isPrimary ? AppColors.primary : colorScheme.surface)
              : null,
          borderRadius: BorderRadius.circular(25),
          border: isPrimary || pillGradient != null
              ? null
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary || pillGradient != null
                  ? Colors.white
                  : colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isPrimary || pillGradient != null
                    ? Colors.white
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHostelTypeBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final options = ['Boys', 'Girls', 'Any'];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wc,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hostel Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Filter hostels by preference',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((type) {
                    IconData icon;
                    if (type == 'Boys') {
                      icon = Icons.male;
                    } else if (type == 'Girls') {
                      icon = Icons.female;
                    } else {
                      icon = Icons.people;
                    }
                    final selected = _selectedHostelTypeFilter == type;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedHostelTypeFilter = type;
                          _updateDisplayList();
                        });
                        Navigator.of(context).pop();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary,
                                  ],
                                )
                              : null,
                          color: selected
                              ? null
                              : colorScheme.surfaceContainerHighest,
                          border: selected
                              ? null
                              : Border.all(
                                  color: colorScheme.outline.withValues(alpha: 0.25),
                                ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: selected ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
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
            color: colorScheme.surface.withValues(alpha: 0.96),
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
              _buildSortOption(context, Icons.local_fire_department, 'Popular', _SortOption.popular),
              _buildSortOption(context, Icons.new_releases, 'Newest', _SortOption.newest),
              _buildSortOption(context, Icons.arrow_upward, 'Price: Low to High', _SortOption.priceLowToHigh),
              _buildSortOption(context, Icons.arrow_downward, 'Price: High to Low', _SortOption.priceHighToLow),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, IconData icon, String text, _SortOption option) {
    final isSelected = _sortBy == option;
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
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _sortBy = option;
          _updateDisplayList();
        });
      },
    );
  }

  void _showCityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SearchCityView(
          selectedCityName: _selectedCityName,
          showAnyOption: true,
          onCitySelected: (name, imagePath, cityForApi) {
            if (!mounted) return;
            setState(() {
              _selectedCityName = name;
              _selectedCityForApi = cityForApi;
            });
            _load();
          },
        ),
      ),
    );
  }

  void _showPriceRangeBottomSheet(BuildContext context) {
    _minPriceController.text = _priceMin != null ? _priceMin!.toStringAsFixed(0) : '';
    _maxPriceController.text = _priceMax != null ? _priceMax!.toStringAsFixed(0) : '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.96),
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
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixText: 'Rs. ',
                              prefixStyle: const TextStyle(color: Colors.black),
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
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Any',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixText: 'Rs. ',
                              prefixStyle: const TextStyle(color: Colors.black),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _minPriceController.clear();
                          _maxPriceController.clear();
                          if (mounted) {
                            setState(() {
                              _priceMin = null;
                              _priceMax = null;
                              _updateDisplayList();
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: AppPrimaryButton(
                          label: 'Apply Filter',
                          onPressed: () {
                            final minStr = _minPriceController.text.trim();
                            final maxStr = _maxPriceController.text.trim();
                            final min = minStr.isEmpty ? null : double.tryParse(minStr.replaceAll(',', ''));
                            final max = maxStr.isEmpty ? null : double.tryParse(maxStr.replaceAll(',', ''));
                            if (min != null && max != null && min > max) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Min price cannot be greater than max price'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            if (mounted) {
                              setState(() {
                                _priceMin = min;
                                _priceMax = max;
                                _updateDisplayList();
                              });
                              Navigator.pop(context);
                            }
                          },
                          height: 54,
                          borderRadius: 27,
                        ),
                      ),
                    ),
                  ],
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
