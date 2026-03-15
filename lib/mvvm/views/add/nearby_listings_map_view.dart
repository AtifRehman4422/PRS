import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';

class NearbyListingsMapView extends StatefulWidget {
  const NearbyListingsMapView({
    super.key,
    this.city,
    this.propertyType,
  });

  final String? city;
  final String? propertyType;

  static Future<void> open(
    BuildContext context, {
    String? city,
    String? propertyType,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NearbyListingsMapView(
          city: city,
          propertyType: propertyType,
        ),
      ),
    );
  }

  @override
  State<NearbyListingsMapView> createState() => _NearbyListingsMapViewState();
}

class _NearbyListingsMapViewState extends State<NearbyListingsMapView> {
  static const LatLng _fallbackCenter = LatLng(33.6844, 73.0479); // Islamabad

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng _userLocation = _fallbackCenter;
  bool _hasUserLocation = false;
  double _radiusMeters = 2000; // initial 2km
  bool _isLoadingLocation = true;
  bool _isLoadingListings = false;
  List<ListingModel> _allListings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _getUserLocation();
    await _loadListings();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
      _hasUserLocation = true;

      if (_mapController.isCompleted) {
        final controller = await _mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _userLocation, zoom: 13),
          ),
        );
      }
    } catch (_) {
      // keep fallback center
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoadingListings = true;
    });
    try {
      final raw = await ListingApi.getListings(
        city: widget.city,
        propertyType: widget.propertyType,
      );
      final list = raw.map((e) => ListingModel.fromJson(e)).toList();
      if (!mounted) return;
      setState(() {
        _allListings = list;
      });
    } catch (_) {
      // ignore errors, just show empty
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingListings = false;
        });
      }
    }
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final aVal = sinDLat * sinDLat + sinDLon * sinDLon * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(aVal), math.sqrt(1 - aVal));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // User marker (blue)
    if (_hasUserLocation) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Listing markers (red) filtered by radius if we have user location
    for (final listing in _allListings) {
      final lat = listing.latitude;
      final lng = listing.longitude;
      if (lat == null || lng == null) continue;
      final pos = LatLng(lat, lng);
      if (_hasUserLocation) {
        final d = _distanceMeters(_userLocation, pos);
        if (d > _radiusMeters) continue;
      }
      markers.add(
        Marker(
          markerId: MarkerId('listing_${listing.id}'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: listing.title,
            snippet: listing.rent != null ? 'Rent: ${listing.rent!.toStringAsFixed(0)}' : null,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> get _circles {
    if (!_hasUserLocation) return {};
    return {
      Circle(
        circleId: const CircleId('radius'),
        center: _userLocation,
        radius: _radiusMeters,
        strokeWidth: 2,
        strokeColor: AppColors.primary.withValues(alpha: 0.8),
        fillColor: AppColors.primary.withValues(alpha: 0.15),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby on Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation,
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  markers: _markers,
                  circles: _circles,
                ),
                if (_isLoadingLocation || _isLoadingListings)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isLoadingLocation ? 'Getting your location…' : 'Loading listings…',
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 10, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${_radiusMeters.toStringAsFixed(0)} meters',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _radiusMeters,
                    min: 500,
                    max: 5000,
                    divisions: 18,
                    label: '${_radiusMeters.toStringAsFixed(0)} m',
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _radiusMeters = value;
                      });
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

