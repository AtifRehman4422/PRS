import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/data/datasource/favorites_api.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/auth/login_view.dart';
import 'package:propertyrent/mvvm/views/home/widgets/property_card.dart';
import 'package:propertyrent/mvvm/views/home/advertiser_ads_view.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PropertyDetailView extends ConsumerStatefulWidget {
  final int? listingId;
  final Map<String, dynamic>? property;

  const PropertyDetailView({super.key, this.listingId, this.property})
      : assert(listingId != null || property != null);

  @override
  ConsumerState<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends ConsumerState<PropertyDetailView> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  Timer? _timer;

  List<String> images = [];
  String title = '';
  String location = '';
  String subLocation = '';
  String price = '0';
  int bedrooms = 0;
  int bathrooms = 0;

  ListingModel? _listing;
  double? _latitude;
  double? _longitude;
  bool _loading = true;
  bool _isFavorite = false;
  List<ListingModel> _recommended = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.property != null) {
      _initializeFromMap(widget.property!);
      _loading = false;
    } else {
      _loadListing();
    }
    _startAutoSlide();
  }

  void _initializeFromMap(Map<String, dynamic> prop) {
    images = (prop['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (images.isEmpty) images = [AppImages.home];
    title = prop['title'] ?? 'Property';
    location = prop['location'] ?? 'Location';
    subLocation = prop['subLocation'] ?? '';
    price = prop['price'] ?? '0';
    bedrooms = prop['bedrooms'] ?? 0;
    bathrooms = prop['bathrooms'] ?? 0;
    final lat = prop['latitude'];
    final lng = prop['longitude'];
    if (lat is num) _latitude = lat.toDouble();
    if (lng is num) _longitude = lng.toDouble();
  }

  Future<void> _loadListing() async {
    if (widget.listingId == null) return;
    final data = await ListingApi.getListingById(widget.listingId!);
    if (!mounted) return;
    if (data != null) {
      _listing = ListingModel.fromJson(data);
      images = _listing!.imageUrls;
      if (images.isEmpty) images = [AppImages.home];
      title = _listing!.title;
      location = _listing!.location;
      subLocation = _listing!.subLocation;
      price = _listing!.price;
      bedrooms = _listing!.bedrooms;
      bathrooms = _listing!.bathrooms;
      _latitude = _listing!.latitude;
      _longitude = _listing!.longitude;
    }
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token != null) _isFavorite = await FavoritesApi.check(token, widget.listingId!);
    if (mounted) {
      setState(() => _loading = false);
      _loadRecommended();
    }
  }

  Future<void> _loadRecommended() async {
    final base = _listing;
    if (base == null) return;

    final listJson = await ListingApi.getListings(
      city: base.city.isNotEmpty ? base.city : null,
      propertyType: base.propertyType.isNotEmpty ? base.propertyType : null,
    );
    var list = listJson.map((e) => ListingModel.fromJson(e)).toList();

    // Same type, same city, exclude current
    list = list.where((l) => l.id != base.id).toList();

    // Price <= current price (if available)
    final baseRent = base.rent ?? 0;
    if (baseRent > 0) {
      list = list.where((l) => (l.rent ?? 0) <= baseRent).toList();
    }

    // Sort by price ascending and limit
    list.sort((a, b) => (a.rent ?? 0).compareTo(b.rent ?? 0));
    if (list.length > 10) {
      list = list.take(10).toList();
    }

    if (!mounted) return;
    setState(() {
      _recommended = list;
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.listingId == null) return;
    final token = await ref.read(authRepositoryProvider).getAuthToken();
    if (token == null || token.isEmpty) return;
    final ok = _isFavorite
        ? await FavoritesApi.remove(token, widget.listingId!)
        : await FavoritesApi.add(token, widget.listingId!);
    if (!mounted || !ok) return;
    setState(() => _isFavorite = !_isFavorite);
    final added = _isFavorite;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added ? 'Added to favorites' : 'Removed from favorites'),
        backgroundColor: added ? Colors.green : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startAutoSlide() {
    if (images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentImageIndex < images.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleContact(String label) async {
    final phone = _listing?.contactPhone;
    final whatsapp = _listing?.whatsapp ?? phone;
    if (label == 'Call') {
      if (phone == null || phone.isEmpty) return;
      final uri = 'tel:${phone.trim()}';
      if (await canLaunchUrlString(uri)) {
        await launchUrlString(uri);
      }
    } else if (label == 'SMS') {
      if (phone == null || phone.isEmpty) return;
      final uri = 'sms:${phone.trim()}';
      if (await canLaunchUrlString(uri)) {
        await launchUrlString(uri);
      }
    } else if (label == 'WhatsApp') {
      if (whatsapp == null || whatsapp.isEmpty) return;
      final cleaned = whatsapp.replaceAll(RegExp(r'\\s+'), '');
      final uri = 'https://wa.me/$cleaned';
      if (await canLaunchUrlString(uri)) {
        await launchUrlString(uri);
      }
    }
  }

  void _openImageGallery() {
    if (images.isEmpty) return;
    final controller = PageController(initialPage: _currentImageIndex);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final url = images[index];
                  if (url.startsWith('http')) {
                    return InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }
                  return InteractiveViewer(
                    child: Center(
                      child: Image.asset(
                        url,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openInGoogleMaps() async {
    final lat = _latitude ?? _listing?.latitude;
    final lng = _longitude ?? _listing?.longitude;
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  void _showReportDialog() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const LoginView(),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportAdSheet(
        listingId: _listing?.id ?? widget.listingId,
        listingTitle: title,
        userEmail: user.email ?? '',
      ),
    );
  }

  void _showFullDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FullDetailsSheet(
        title: title,
        description: _listing?.description ?? 'No description.',
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        listing: _listing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  AppImages.logo,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Column(
            children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Image Slider
                        GestureDetector(
                          onTap: _openImageGallery,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final url = images[index];
                              if (url.startsWith('http')) {
                                return Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 350,
                                );
                              }
                              return Image.asset(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 350,
                              );
                            },
                          ),
                        ),
                        // Curved Bottom Mask
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        // Back Button & Favorite
                        Positioned(
                          top: 40,
                          left: 20,
                          right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Favorite Button
                              InkWell(
                                onTap: _toggleFavorite,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 22,
                                  color: _isFavorite ? AppColors.primary : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Image Counter Badge (1/X)
                        Positioned(
                          bottom: 40,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title, Location & Price
                        FadeInSlide(
                          delay: 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 18,
                                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '$location${subLocation.isNotEmpty ? ', $subLocation' : ''}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'PKR $price',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Features Row
                        FadeInSlide(
                          delay: 0.4,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              // children: [
                              //   _buildFeatureChip(
                              //     Icons.bed_outlined,
                              //     '$bedrooms Beds',
                              //   ),
                              //   const SizedBox(width: 12),
                              //   _buildFeatureChip(
                              //     Icons.bathtub_outlined,
                              //     '$bathrooms Baths',
                              //   ),
                              //   const SizedBox(width: 12),
                              //   if (_listing?.extras?['kitchen'] != null)
                              //     _buildFeatureChip(
                              //       Icons.kitchen_outlined,
                              //       '${_listing!.extras!['kitchen']} Kitchen(s)',
                              //     ),
                              // ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Ad Posted By Section
                        FadeInSlide(
                          delay: 0.45,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ad Posted By',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.surfaceContainerHighest,
                                        image: const DecorationImage(
                                          image: AssetImage(AppImages.one),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _listing?.ownerName ?? 'Owner',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _listing?.location ?? location,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      final listing = _listing;
                                      if (listing == null || listing.userId == null) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdvertiserAdsView(
                                            advertiserName: listing.ownerName ??
                                                listing.username ??
                                                'Advertiser',
                                            userId: listing.userId!,
                                            propertyType: listing.propertyType,
                                            excludeListingId: listing.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View More Ads by this Advertiser',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Report Ad
                        FadeInSlide(
                          delay: 0.5,
                          child: Center(
                            child: TextButton.icon(
                              onPressed: _showReportDialog,
                              icon: const Icon(
                                Icons.flag_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              label: const Text(
                                'Report This Ad',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        FadeInSlide(
                          delay: 0.55,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _listing?.description ?? 'No description.',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              // View Full Description
                              TextButton(
                                onPressed: _showFullDetails,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  'View Full Description & Feature',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Location Map
                        FadeInSlide(
                          delay: 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View on Location',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 220,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: (_latitude != null && _longitude != null)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          children: [
                                            GoogleMap(
                                              initialCameraPosition: CameraPosition(
                                                target: LatLng(_latitude!, _longitude!),
                                                zoom: 15,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId('listing'),
                                                  position: LatLng(_latitude!, _longitude!),
                                                ),
                                              },
                                              myLocationButtonEnabled: false,
                                              zoomControlsEnabled: false,
                                              onTap: (_) => _openInGoogleMaps(),
                                            ),
                                            Positioned(
                                              left: 12,
                                              right: 12,
                                              bottom: 12,
                                              child: SizedBox(
                                                height: 40,
                                                width: double.infinity,
                                                child: AppPrimaryButton(
                                                  label: 'Open in Google Maps',
                                                  icon: Icons.map,
                                                  onPressed: _openInGoogleMaps,
                                                  height: 40,
                                                  borderRadius: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'Location not available',
                                          style: TextStyle(
                                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Recommended Properties
                        FadeInSlide(
                          delay: 0.65,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended Properties',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_recommended.isEmpty)
                                Text(
                                  'No recommended properties yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 300,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _recommended.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final rec = _recommended[index];
                                      final recImages = rec.imageUrls;
                                      return SizedBox(
                                        width: 240,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PropertyDetailView(
                                                  listingId: rec.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: PropertyCard(
                                            compact: true,
                                            imageHeight: 140,
                                            showBadges: false,
                                            title: rec.title,
                                            location: rec.location,
                                            subLocation: rec.subLocation,
                                            price: rec.price,
                                            bedrooms: rec.bedrooms,
                                            bathrooms: rec.bathrooms,
                                            images: recImages.isEmpty ? const [AppImages.home] : recImages,
                                            createdAt: rec.createdAt,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Bar
          FadeInSlide(
            delay: 0.7,
            duration: 0.8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildContactButton(Icons.call, 'Call'),
                  const SizedBox(width: 16),
                  _buildContactButton(Icons.message, 'SMS'),
                  const SizedBox(width: 16),
                  _buildContactButton(Icons.chat, 'WhatsApp'),
                ],
              ),
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleContact(label),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// ---- Dialogs & Sheets ----

class ReportAdSheet extends ConsumerStatefulWidget {
  final int? listingId;
  final String? listingTitle;
  final String? userEmail;

  const ReportAdSheet({super.key, this.listingId, this.listingTitle, this.userEmail});

  @override
  ConsumerState<ReportAdSheet> createState() => _ReportAdSheetState();
}

class _ReportAdSheetState extends ConsumerState<ReportAdSheet> {
  int _selectedReason = 4;
  final List<String> reasons = [
    'Property location is wrong',
    'Inaccurate property images',
    'Unauthorized use of images',
    'Unauthorized use of property',
    'Property is not available',
  ];
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      _contactController.text = widget.userEmail!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.96,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report This Ad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      splashRadius: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This won\'t be shared with the advertiser.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(reasons.length, (index) {
                      return RadioListTile<int>(
                        value: index,
                        groupValue: _selectedReason,
                        onChanged: (val) {
                          setState(() => _selectedReason = val!);
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                        title: Text(
                          reasons[index],
                          style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _detailsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Issue details',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          hintText: 'Your contact (email or phone)',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final listingId = widget.listingId;
                              if (listingId == null) {
                                Navigator.pop(context);
                                return;
                              }
                              final reason = reasons[_selectedReason];
                              final details = _detailsController.text.trim();
                              final contact = _contactController.text.trim();

                              final repo = ref.read(authRepositoryProvider);
                              final token = await repo.getAuthToken();
                              if (token == null || token.isEmpty) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login again to submit report.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final result = await ListingApi.reportListing(
                                token: token,
                                listingId: listingId,
                                reason: reason,
                                details: details.isEmpty ? null : details,
                                contact: contact.isEmpty ? null : contact,
                              );

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.success
                                        ? 'Report for this ad has been saved successfully.'
                                        : (result.message ?? 'Failed to submit report'),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor:
                                      result.success ? Colors.green : AppColors.primary,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Submit Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem(this.icon, this.label, this.value);
}

List<_DetailItem> _buildDetailItems(ListingModel? listing, int bedrooms, int bathrooms) {
  final list = <_DetailItem>[];
  list.add(_DetailItem(Icons.bed_outlined, 'Bedrooms', '$bedrooms'));
  list.add(_DetailItem(Icons.bathtub_outlined, 'Bathrooms', '$bathrooms'));
  if (listing != null) {
    if ((listing.areaSize ?? 0) > 0) {
      list.add(_DetailItem(
        Icons.square_foot,
        'Area',
        '${listing.areaSize!.toStringAsFixed(0)} ${listing.areaUnit ?? ''}',
      ));
    }
    final extras = listing.extras;
    if (extras != null) {
      if (extras['kitchen'] != null) list.add(_DetailItem(Icons.kitchen_outlined, 'Kitchen', '${extras['kitchen']}'));
      if (extras['tv_lounge'] != null) list.add(_DetailItem(Icons.tv, 'TV Lounge', '${extras['tv_lounge']}'));
      if (extras['laundry'] != null) list.add(_DetailItem(Icons.local_laundry_service, 'Laundry', '${extras['laundry']}'));
      if (extras['mess'] != null) list.add(_DetailItem(Icons.restaurant, 'Mess', '${extras['mess']}'));
    }
    final td = listing.typeDetails;
    if (td != null) {
      switch (listing.propertyType) {
        case 'Hostel':
          if (td['hostel_type'] != null) list.add(_DetailItem(Icons.wc, 'Hostel Type', '${td['hostel_type']}'));
          if (td['beds'] != null) list.add(_DetailItem(Icons.single_bed, 'Beds', '${td['beds']}'));
          if (td['room_type'] != null) list.add(_DetailItem(Icons.meeting_room, 'Room Type', '${td['room_type']}'));
          if (td['ac'] == true) list.add(_DetailItem(Icons.ac_unit, 'AC', 'Yes'));
          if (td['wifi'] == true) list.add(_DetailItem(Icons.wifi, 'WiFi', 'Yes'));
          if (td['food_included'] == true) list.add(_DetailItem(Icons.restaurant, 'Food Included', 'Yes'));
          if (td['preference'] != null) list.add(_DetailItem(Icons.people, 'Preference', '${td['preference']}'));
          if (td['in_time_rules'] != null && td['in_time_rules'].toString().isNotEmpty) list.add(_DetailItem(Icons.access_time, 'In Time', '${td['in_time_rules']}'));
          break;
        case 'House':
        case 'Flat':
          if (td['portion'] != null) list.add(_DetailItem(Icons.home_work_outlined, 'Portion', '${td['portion']}'));
          if (td['bhk'] != null) list.add(_DetailItem(Icons.door_front_door, 'BHK', '${td['bhk']}'));
          if (td['furnished'] != null) list.add(_DetailItem(Icons.chair, 'Furnished', '${td['furnished']}'));
          if (td['balcony'] == true) list.add(_DetailItem(Icons.balcony, 'Balcony', 'Yes'));
          if (td['lift'] == true) list.add(_DetailItem(Icons.elevator, 'Lift', 'Yes'));
          if (td['parking'] == true) list.add(_DetailItem(Icons.local_parking, 'Parking', 'Yes'));
          if (td['preference'] != null) list.add(_DetailItem(Icons.people, 'Preference', '${td['preference']}'));
          break;
        case 'Shop':
          if (td['shop_location'] != null) list.add(_DetailItem(Icons.store, 'Location Type', '${td['shop_location']}'));
          if (td['front_type'] != null) list.add(_DetailItem(Icons.door_front_door, 'Front Type', '${td['front_type']}'));
          if (td['suitable_for'] != null) list.add(_DetailItem(Icons.business, 'Suitable For', '${td['suitable_for']}'));
          break;
        case 'Office':
          if (td['furnished'] != null) list.add(_DetailItem(Icons.chair, 'Furnished', '${td['furnished']}'));
          if (td['cabins'] != null) list.add(_DetailItem(Icons.meeting_room, 'Cabins', '${td['cabins']}'));
          if (td['workstations'] != null) list.add(_DetailItem(Icons.computer, 'Workstations', '${td['workstations']}'));
          if (td['suitable_for'] != null) list.add(_DetailItem(Icons.business, 'Suitable For', '${td['suitable_for']}'));
          break;
        case 'Hotel':
          if (td['rooms'] != null) list.add(_DetailItem(Icons.hotel, 'Rooms', '${td['rooms']}'));
          if (td['ac_type'] != null) list.add(_DetailItem(Icons.ac_unit, 'AC Type', '${td['ac_type']}'));
          if (td['wifi'] == true) list.add(_DetailItem(Icons.wifi, 'Free Wi-Fi', 'Yes'));
          if (td['parking'] == true) list.add(_DetailItem(Icons.local_parking, 'Parking', 'Yes'));
          if (td['room_service'] == true) list.add(_DetailItem(Icons.room_service, 'Room Service', 'Yes'));
          if (td['cctv'] == true) list.add(_DetailItem(Icons.security, 'CCTV', 'Yes'));
          break;
        case 'Marquee':
          if (td['max_guests'] != null) list.add(_DetailItem(Icons.groups, 'Max Guests', '${td['max_guests']}'));
          if (td['catering'] != null) list.add(_DetailItem(Icons.restaurant, 'Catering', '${td['catering']}'));
          if (td['suitable_for'] != null) list.add(_DetailItem(Icons.celebration, 'Suitable For', '${td['suitable_for']}'));
          break;
        case 'Guest House':
          if (td['rooms'] != null) list.add(_DetailItem(Icons.meeting_room, 'Rooms', '${td['rooms']}'));
          if (td['preference'] != null) list.add(_DetailItem(Icons.people, 'Preference', '${td['preference']}'));
          break;
        case 'Farm House':
          if (td['suitable_for'] != null) list.add(_DetailItem(Icons.celebration, 'Suitable For', '${td['suitable_for']}'));
          break;
      }
    }
  }
  return list;
}

class FullDetailsSheet extends StatelessWidget {
  final String title;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final ListingModel? listing;

  const FullDetailsSheet({
    super.key,
    required this.title,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final detailItems = _buildDetailItems(listing, bedrooms, bathrooms);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.9), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Full Description & Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 22),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FadeInSlide(
                  delay: 0.05,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.home_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: colorScheme.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeInSlide(
                  delay: 0.1,
                  child: Text(
                    'All Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(detailItems.length, (i) {
                  final item = detailItems[i];
                  return FadeInSlide(
                    delay: 0.12 + (i * 0.03),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildFeatureRow(context, item.icon, item.label, item.value, colorScheme),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String label, String value, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
