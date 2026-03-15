import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/data/datasource/favorites_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/mvvm/views/home/listing_feature_chips.dart';
import 'package:propertyrent/mvvm/views/home/property_detail_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  List<ListingModel> _allListings = [];
  List<ListingModel> _listings = [];
  bool _loading = true;
  bool _hasToken = false;
  String? _selectedType;
  final List<String> _types = const [
    'Hostel',
    'Hotel',
    'House',
    'Flat',
    'Shop',
    'Office',
  ];

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _hasToken = false;
          _allListings = [];
          _listings = [];
          _loading = false;
        });
      }
      return;
    }
    _hasToken = true;
    final list = await FavoritesApi.list(token);
    if (!mounted) return;
    final models = list.map((e) => ListingModel.fromJson(e)).toList();

    // Default selected type: current property's type or first available
    if (_selectedType == null && models.isNotEmpty) {
      _selectedType = models.first.propertyType;
    }

    _allListings = models;
    if (_selectedType != null) {
      _listings =
          _allListings.where((l) => l.propertyType == _selectedType).toList();
    } else {
      _listings = [];
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _removeFavorite(BuildContext context, int listingId) async {
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null) return;
    final ok = await FavoritesApi.remove(token, listingId);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    _load();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Favorites',
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
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : !_hasToken
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 64,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Please login to see your favorites.',
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _allListings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppColors.primary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: _types
                                      .map(
                                        (t) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: ChoiceChip(
                                            label: Text(t),
                                            selected: _selectedType == t,
                                            selectedColor:
                                                AppColors.primary,
                                            labelStyle: TextStyle(
                                              color: _selectedType == t
                                                  ? Colors.white
                                                  : colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            onSelected: (selected) {
                                              if (!selected) return;
                                              setState(() {
                                                _selectedType = t;
                                                _listings = _allListings
                                                    .where((l) =>
                                                        l.propertyType ==
                                                        _selectedType)
                                                    .toList();
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: _listings.isEmpty
                                    ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          const SizedBox(height: 200),
                                          Center(
                                            child: Text(
                                              _selectedType == null
                                                  ? 'No favorites found.'
                                                  : 'No ${_selectedType!} favorites yet.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.7),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 200),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        itemCount: _listings.length,
                                        itemBuilder: (context, index) {
                                          final listing = _listings[index];
                                          final images = listing.imageUrls;
                                          return FadeInSlide(
                                            delay: 0.1 + index * 0.05,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PropertyDetailView(
                                                      listingId: listing.id,
                                                    ),
                                                  ),
                                                ).then((_) => _load());
                                              },
                                              child: PropertyCard(
                                                title: listing.title,
                                                location: listing.location,
                                                subLocation:
                                                    listing.subLocation,
                                                addressLine: listing.address ??
                                                    listing.sector ??
                                                    listing.landmark,
                                                cityDisplay: listing.location,
                                                topFeatureChips:
                                                    buildThreeFeatureChips(
                                                        context, listing),
                                                price: listing.price,
                                                bedrooms: listing.bedrooms,
                                                bathrooms: listing.bathrooms,
                                                images: images.isEmpty
                                                    ? [AppImages.home]
                                                    : images,
                                                isFavorite: true,
                                                onFavoriteTap: () =>
                                                    _removeFavorite(
                                                        context, listing.id),
                                                createdAt: listing.createdAt,
                                                showFeaturesRow: false,
                                                statusColor: Colors.green,
                                                onCallTap: () =>
                                                    _launchDialer(
                                                        listing.contactPhone),
                                                onWhatsAppTap: () =>
                                                    _launchWhatsApp(
                                                  listing.whatsapp ??
                                                      listing.contactPhone,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
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
