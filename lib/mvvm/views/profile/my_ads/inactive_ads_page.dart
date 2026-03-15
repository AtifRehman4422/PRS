import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/data/datasource/auth_api.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/mvvm/views/home/listing_feature_chips.dart';
import 'package:propertyrent/mvvm/views/add/add_view.dart';

class InactiveAdsPage extends ConsumerStatefulWidget {
  const InactiveAdsPage({super.key});

  @override
  ConsumerState<InactiveAdsPage> createState() => _InactiveAdsPageState();
}

class _InactiveAdsPageState extends ConsumerState<InactiveAdsPage> {
  List<ListingModel> _allAds = [];
  List<ListingModel> _ads = [];
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
          _allAds = [];
          _ads = [];
          _loading = false;
        });
      }
      return;
    }
    final profile = await AuthApi.getProfile(token);
    final userId = profile?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _hasToken = true;
    final list = await ListingApi.getListings(userId: userId);
    if (!mounted) return;
    final models = list.map((e) => ListingModel.fromJson(e)).toList();
    final inactiveOnly = models.where((l) => (l.status ?? 'active').toLowerCase() != 'active').toList();
    if (_selectedType == null && inactiveOnly.isNotEmpty) {
      _selectedType = inactiveOnly.first.propertyType;
    }
    _allAds = inactiveOnly;
    if (_selectedType != null) {
      _ads = _allAds.where((l) => l.propertyType == _selectedType).toList();
    } else {
      _ads = [];
    }
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _deleteAd(BuildContext context, ListingModel listing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ad?'),
        content: Text('Delete "${listing.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null) return;
    final result = await ListingApi.deleteListing(token: token, listingId: listing.id);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad deleted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to delete'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(AppImages.logo, fit: BoxFit.cover, alignment: Alignment.center),
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
                  children: _types
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(t),
                              selected: _selectedType == t,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedType == t ? Colors.white : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                if (!selected) return;
                                setState(() {
                                  _selectedType = t;
                                  _ads = _allAds.where((l) => l.propertyType == t).toList();
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : !_hasToken
                      ? Center(
                          child: Text(
                            'Please login to see your ads.',
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                          ),
                        )
                      : _ads.isEmpty
                          ? Center(
                              child: Text(
                                _selectedType == null
                                    ? 'No inactive (expired) ads.'
                                    : 'No $_selectedType ads in inactive.',
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _ads.length,
                              itemBuilder: (context, index) {
                                final ad = _ads[index];
                                final images = ad.imageUrls;
                                return FadeInSlide(
                                  delay: 0.1 + index * 0.05,
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
                                      images: images.isEmpty ? [AppImages.home] : images,
                                      isOwner: true,
                                      showBadges: true,
                                      statusText: 'Inactive',
                                      statusColor: Colors.orange,
                                      showFeaturesRow: false,
                                      createdAt: ad.createdAt,
                                      onEditTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddView(listingId: ad.id),
                                          ),
                                        ).then((result) {
                                          _load();
                                          if (result == true && mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Row(
                                                  children: [
                                                    Icon(Icons.check_circle, color: Colors.white, size: 22),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Ad updated successfully!',
                                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                                duration: const Duration(seconds: 2),
                                                margin: const EdgeInsets.all(16),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      onDeleteTap: () => _deleteAd(context, ad),
                                    ),
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
