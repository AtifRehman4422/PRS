import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/data/datasource/favorites_api.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/home/property_detail_view.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/mvvm/views/home/listing_feature_chips.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdvertiserAdsView extends ConsumerStatefulWidget {
  final String advertiserName;
  final int userId;
  final String propertyType;
  final int excludeListingId;

  const AdvertiserAdsView({
    super.key,
    required this.advertiserName,
    required this.userId,
    required this.propertyType,
    required this.excludeListingId,
  });

  @override
  ConsumerState<AdvertiserAdsView> createState() => _AdvertiserAdsViewState();
}

class _AdvertiserAdsViewState extends ConsumerState<AdvertiserAdsView> {
  bool _loading = true;
  List<ListingModel> _allAds = [];
  List<ListingModel> _ads = [];
  Set<int> _favoriteIds = {};
  String? _selectedType;
  final List<String> _types = const [
    'Hostel',
    'Hotel',
    'House',
    'Flat',
    'Shop',
    'Office',
  ];

  @override
  void initState() {
    super.initState();
    // Default chip = current property type if in our fixed list, otherwise first.
    if (_types.contains(widget.propertyType)) {
      _selectedType = widget.propertyType;
    } else {
      _selectedType = _types.first;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ListingApi.getListings(
      city: null,
      userId: widget.userId,
    );
    final models = list.map((e) => ListingModel.fromJson(e)).toList();

    // Load favorites for this viewer (if logged in)
    Set<int> favIds = {};
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token != null && token.isNotEmpty) {
      final favList = await FavoritesApi.list(token);
      favIds = favList
          .map((e) => (e['id'] as num?)?.toInt() ?? 0)
          .where((id) => id > 0)
          .toSet();
    }

    _allAds = models;
    _favoriteIds = favIds;
    if (_selectedType != null) {
      _ads = _allAds.where((l) => l.propertyType == _selectedType).toList();
    } else {
      _ads = [];
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(ListingModel ad) async {
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null || token.isEmpty) return;
    final isFav = _favoriteIds.contains(ad.id);
    final ok =
        isFav ? await FavoritesApi.remove(token, ad.id) : await FavoritesApi.add(token, ad.id);
    if (!mounted || !ok) return;
    setState(() {
      if (isFav) {
        _favoriteIds.remove(ad.id);
      } else {
        _favoriteIds.add(ad.id);
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
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.advertiserName,
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
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: _loading
                ? ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ],
                  )
                : _allAds.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 200),
                          Center(
                            child: Text(
                              'This advertiser has no ads yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 200),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: _types
                                  .map(
                                    (t) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(t),
                                        selected: _selectedType == t,
                                        selectedColor: AppColors.primary,
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
                                            _ads = _allAds
                                                .where(
                                                    (l) => l.propertyType == _selectedType)
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
                            child: _ads.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      const SizedBox(height: 200),
                                      Center(
                                        child: Text(
                                          _selectedType == null
                                              ? 'No ads available for this advertiser.'
                                              : 'No ${_selectedType!} ads available for this advertiser.',
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
                                      vertical: 8,
                                    ),
                                    itemCount: _ads.length,
                                    itemBuilder: (context, index) {
                                      final ad = _ads[index];
                                      final images = ad.imageUrls;
                                      return FadeInSlide(
                                        delay: 0.1 + index * 0.05,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PropertyDetailView(
                                                  listingId: ad.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: PropertyCard(
                                              title: ad.title,
                                              location: ad.location,
                                              subLocation: ad.subLocation,
                                              addressLine: ad.address ?? ad.sector ?? ad.landmark,
                                              cityDisplay: ad.location,
                                              topFeatureChips: buildThreeFeatureChips(context, ad),
                                              price: ad.price,
                                              bedrooms: ad.bedrooms,
                                              bathrooms: ad.bathrooms,
                                              images: images.isEmpty
                                                  ? [AppImages.home]
                                                  : images,
                                              createdAt: ad.createdAt,
                                              showFeaturesRow: false,
                                              statusColor: Colors.green,
                                              isFavorite: _favoriteIds.contains(ad.id),
                                              onFavoriteTap: () => _toggleFavorite(ad),
                                              onCallTap: () => _launchDialer(ad.contactPhone),
                                              onWhatsAppTap: () =>
                                                  _launchWhatsApp(ad.whatsapp ?? ad.contactPhone),
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

