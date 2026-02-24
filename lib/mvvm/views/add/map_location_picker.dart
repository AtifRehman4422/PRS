import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';

/// One search result: lat/lng + display address.
class _SearchResult {
  const _SearchResult({required this.latLng, required this.address});
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

  /// Returns selected address when user taps Save; null if cancelled.
  static Future<String?> open(BuildContext context, {String? initialAddress}) async {
    return Navigator.of(context).push<String>(
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
  static const LatLng _defaultCenter = LatLng(31.5204, 74.3587); // Lahore, Pakistan

  final TextEditingController _addressController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng _selectedPosition = _defaultCenter;
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  String? _searchError;
  List<_SearchResult> _suggestions = [];
  bool _mapCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null && widget.initialAddress!.trim().isNotEmpty) {
      _addressController.text = widget.initialAddress!.trim();
      _currentAddress = widget.initialAddress!.trim();
      _searchByAddress(widget.initialAddress!.trim());
    } else {
      _currentAddress = 'Lahore, Pakistan';
      _addressController.text = _currentAddress;
      _reverseGeocode(_defaultCenter);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _searchByAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
      _suggestions = [];
    });
    try {
      final locations = await locationFromAddress(query.trim());
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchError = 'Address not found. Try different words (e.g. city, area).';
        });
        return;
      }
      // Build suggestions with reverse-geocoded addresses (max 5)
      final results = <_SearchResult>[];
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
        results.add(_SearchResult(latLng: latLng, address: address));
      }
      if (!mounted) return;
      if (results.length == 1) {
        final controller = await _mapController.future;
        await controller.animateCamera(CameraUpdate.newLatLngZoom(results.first.latLng, 15));
        setState(() {
          _selectedPosition = results.first.latLng;
          _currentAddress = results.first.address;
          _addressController.text = results.first.address;
          _isSearching = false;
          _suggestions = [];
        });
      } else {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _suggestions = [];
          _searchError = 'Search failed. Check internet or try another address.';
        });
      }
    }
  }

  void _pickSuggestion(_SearchResult result) async {
    setState(() {
      _selectedPosition = result.latLng;
      _currentAddress = result.address;
      _addressController.text = result.address;
      _suggestions = [];
    });
    try {
      final controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(result.latLng, 15));
    } catch (_) {}
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
      setState(() {
        _currentAddress = address;
        _addressController.text = address;
        _isLoadingAddress = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentAddress = '${position.latitude}, ${position.longitude}';
          _addressController.text = _currentAddress;
          _isLoadingAddress = false;
        });
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
    Navigator.of(context).pop(address.isNotEmpty ? address : null);
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
                    hintText: 'Address type karein, phir Search ya Enter dabayein',
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
                            onPressed: () => _searchByAddress(_addressController.text.trim()),
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  onSubmitted: _searchByAddress,
                  textInputAction: TextInputAction.search,
                ),
                if (_searchError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _searchError!,
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                  ),
                ],
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap a suggestion:',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._suggestions.map((r) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.place, color: AppColors.primary, size: 22),
                    title: Text(
                      r.address,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _pickSuggestion(r),
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
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
