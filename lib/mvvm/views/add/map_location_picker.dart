import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/data/datasource/place_autocomplete_api.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';

/// Fallback when Place Autocomplete returns no results (e.g. PWD, sector names).
class _GeocodeSuggestion {
  const _GeocodeSuggestion({required this.latLng, required this.address});
  final LatLng latLng;
  final String address;
}

/// Full-screen map picker: user enters address (location shows on map) or moves map;
/// Save closes and returns the selected address.
class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({
    super.key,
    this.initialAddress,
  });

  final String? initialAddress;

  /// Returns { address, latitude, longitude } when user taps Save; null if cancelled.
  static Future<Map<String, dynamic>?> open(BuildContext context, {String? initialAddress}) async {
    return Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(initialAddress: initialAddress),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  static const LatLng _defaultCenter = LatLng(33.6844, 73.0479); // Islamabad area fallback

  final TextEditingController _addressController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng _selectedPosition = _defaultCenter;
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  String? _searchError;
  List<PlacePrediction> _placeSuggestions = [];
  List<_GeocodeSuggestion> _geocodeSuggestions = [];
  bool _mapCreated = false;
  bool _isProgrammaticUpdate = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null && widget.initialAddress!.trim().isNotEmpty) {
      _isProgrammaticUpdate = true;
      _addressController.text = widget.initialAddress!.trim();
      _currentAddress = widget.initialAddress!.trim();
      _searchByAddress(widget.initialAddress!.trim());
    } else {
      _addressController.clear();
      _getCurrentLocationAndCenter();
    }
    _addressController.addListener(_onAddressTextChanged);
  }

  void _onAddressTextChanged() {
    if (_isProgrammaticUpdate) return;
    _debounceTimer?.cancel();
    final query = _addressController.text.trim();
    if (query.length < 2) {
      setState(() {
        _placeSuggestions = [];
        _geocodeSuggestions = [];
        _searchError = null;
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchPlaceSuggestions(query);
    });
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
      _placeSuggestions = [];
      _geocodeSuggestions = [];
    });
    try {
      // 1) Try Google Place Autocomplete first
      var list = await PlaceAutocompleteApi.getSuggestions(query.trim());
      if (!mounted) return;
      if (list.isNotEmpty) {
        setState(() {
          _placeSuggestions = list;
          _geocodeSuggestions = [];
          _isSearching = false;
        });
        return;
      }
      // 2) Fallback: Geocoding API (PWD, sector names, areas jo Place me nahi milte)
      final locations = await locationFromAddress(query.trim());
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchError = 'Koi location nahi mili. Alag naam try karein (e.g. PWD Islamabad).';
        });
        return;
      }
      final results = <_GeocodeSuggestion>[];
      for (var i = 0; i < locations.length && i < 5; i++) {
        final loc = locations[i];
        final latLng = LatLng(loc.latitude, loc.longitude);
        String address = query.trim();
        try {
          final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            address = [p.street, p.subLocality, p.locality, p.administrativeArea, p.country]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(', ');
          }
        } catch (_) {}
        results.add(_GeocodeSuggestion(latLng: latLng, address: address));
      }
      if (!mounted) return;
      setState(() {
        _geocodeSuggestions = results;
        _placeSuggestions = [];
        _isSearching = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _placeSuggestions = [];
          _geocodeSuggestions = [];
          _searchError = 'Suggestions load nahi ho paye. Internet check karein.';
        });
      }
    }
  }

  void _pickGeocodeSuggestion(_GeocodeSuggestion g) {
    _isProgrammaticUpdate = true;
    setState(() {
      _selectedPosition = g.latLng;
      _currentAddress = g.address;
      _addressController.text = g.address;
      _placeSuggestions = [];
      _geocodeSuggestions = [];
      _searchError = null;
    });
    _isProgrammaticUpdate = false;
    _mapController.future.then((controller) async {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(g.latLng, 15));
    });
  }

  Future<void> _pickPlaceSuggestion(PlacePrediction prediction) async {
    setState(() => _isLoadingAddress = true);
    try {
      final details = await PlaceAutocompleteApi.getPlaceDetails(prediction.placeId);
      if (!mounted) return;
      if (details == null) {
        setState(() {
          _isLoadingAddress = false;
          _searchError = 'Location load nahi hua.';
        });
        return;
      }
      final latLng = LatLng(details.lat, details.lng);
      _isProgrammaticUpdate = true;
      setState(() {
        _selectedPosition = latLng;
        _currentAddress = details.formattedAddress;
        _addressController.text = details.formattedAddress;
        _placeSuggestions = [];
        _isLoadingAddress = false;
        _searchError = null;
      });
      _isProgrammaticUpdate = false;
      final controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
          _searchError = 'Location load nahi hua.';
        });
      }
    }
  }

  Future<void> _getCurrentLocationAndCenter() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _moveToDefaultAndReverseGeocode();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      if (mounted) _moveToDefaultAndReverseGeocode();
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (!mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedPosition = latLng);
      _reverseGeocodeForCurrentOnly(latLng);
      final controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } catch (_) {
      if (mounted) _moveToDefaultAndReverseGeocode();
    }
  }

  void _moveToDefaultAndReverseGeocode() {
    setState(() => _selectedPosition = _defaultCenter);
    _reverseGeocodeForCurrentOnly(_defaultCenter);
    _mapController.future.then((c) async {
      await c.animateCamera(CameraUpdate.newLatLngZoom(_defaultCenter, 12));
    });
  }

  Future<void> _reverseGeocodeForCurrentOnly(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final parts = [
        p?.street,
        p?.subLocality,
        p?.locality,
        p?.administrativeArea,
        p?.country,
      ].whereType<String>().where((s) => s.isNotEmpty).toList();
      _currentAddress = parts.isEmpty ? '${position.latitude}, ${position.longitude}' : parts.join(', ');
    } catch (_) {
      _currentAddress = '${position.latitude}, ${position.longitude}';
    }
    if (mounted) setState(() => _isLoadingAddress = false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _addressController.removeListener(_onAddressTextChanged);
    _addressController.dispose();
    super.dispose();
  }

  /// Used only when opening with initialAddress (geocoding to get lat/lng).
  Future<void> _searchByAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final locations = await locationFromAddress(query.trim());
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchError = 'Address not found. Try different words.';
        });
        return;
      }
      final loc = locations.first;
      final latLng = LatLng(loc.latitude, loc.longitude);
      String address = query.trim();
      try {
        final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = [p.street, p.subLocality, p.locality, p.administrativeArea, p.country]
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}
      if (!mounted) return;
      final controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      _isProgrammaticUpdate = true;
      setState(() {
        _selectedPosition = latLng;
        _currentAddress = address;
        _addressController.text = address;
        _isSearching = false;
      });
      _isProgrammaticUpdate = false;
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchError = 'Search failed. Check internet.';
        });
      }
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final parts = [
        p?.street,
        p?.subLocality,
        p?.locality,
        p?.administrativeArea,
        p?.country,
      ].whereType<String>().where((s) => s.isNotEmpty).toList();
      final address = parts.isEmpty ? '${position.latitude}, ${position.longitude}' : parts.join(', ');
      _isProgrammaticUpdate = true;
      setState(() {
        _currentAddress = address;
        _addressController.text = address;
        _isLoadingAddress = false;
      });
      _isProgrammaticUpdate = false;
    } catch (_) {
      if (mounted) {
        _isProgrammaticUpdate = true;
        setState(() {
          _currentAddress = '${position.latitude}, ${position.longitude}';
          _addressController.text = _currentAddress;
          _isLoadingAddress = false;
        });
        _isProgrammaticUpdate = false;
      }
    }
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedPosition = position);
    _reverseGeocode(position);
  }

  void _onCameraIdle() {
    // Optional: update position when user stops moving map (if you want center = selected)
    // For simplicity we use tap-only; uncomment below to use camera center.
    // _mapController.future.then((c) async {
    //   final pos = await c.getLatLng(ScreenCoordinate(...));
    //   ...
    // });
  }

  void _onSave() {
    final address = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : _currentAddress;
    if (address.isEmpty) {
      Navigator.of(context).pop(null);
      return;
    }
    Navigator.of(context).pop({
      'address': address,
      'latitude': _selectedPosition.latitude,
      'longitude': _selectedPosition.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Address search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Type place',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _fetchPlaceSuggestions(_addressController.text.trim()),
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  onSubmitted: (_) => _fetchPlaceSuggestions(_addressController.text.trim()),
                  textInputAction: TextInputAction.search,
                ),
                if (_searchError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _searchError!,
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                  ),
                ],
                if (_placeSuggestions.isNotEmpty || _geocodeSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Suggestion se select karein:',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._placeSuggestions.map((p) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.place, color: AppColors.primary, size: 22),
                    title: Text(
                      p.description,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _pickPlaceSuggestion(p),
                  )),
                  ..._geocodeSuggestions.map((g) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                    title: Text(
                      g.address,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _pickGeocodeSuggestion(g),
                  )),
                ],
              ],
            ),
          ),
          // Map (with fallback if not created - e.g. API key issue)
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition,
                    zoom: widget.initialAddress != null ? 15 : 12,
                  ),
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                    if (mounted) setState(() => _mapCreated = true);
                  },
                  onTap: _onMapTap,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedPosition,
                      draggable: true,
                      onDragEnd: (LatLng position) {
                        setState(() => _selectedPosition = position);
                        _reverseGeocode(position);
                      },
                    ),
                  },
                ),
                if (!_mapCreated)
                  Positioned.fill(
                    child: Container(
                      color: colorScheme.surface,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Loading map…',
                            style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_mapCreated && _isLoadingAddress)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppPrimaryButton(
              label: 'Save',
              onPressed: _onSave,
              height: 52,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }
}
