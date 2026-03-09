import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:propertyrent/core/constants/api_config.dart';

/// One prediction from Google Place Autocomplete.
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
  });
  final String placeId;
  final String description;
}

/// Result from Place Details: lat, lng, formatted address.
class PlaceDetailsResult {
  const PlaceDetailsResult({
    required this.lat,
    required this.lng,
    required this.formattedAddress,
  });
  final double lat;
  final double lng;
  final String formattedAddress;
}

/// Google Places API (Legacy): Autocomplete + Place Details.
/// Enable "Places API" in Google Cloud Console for this key.
class PlaceAutocompleteApi {
  static const _base = 'https://maps.googleapis.com/maps/api/place';

  /// Place Autocomplete (Legacy) - returns suggestions as user types.
  /// Bias to Pakistan (Islamabad area) so PWD, sectors etc. mil sakein.
  static Future<List<PlacePrediction>> getSuggestions(String input) async {
    if (input.trim().isEmpty) return [];
    final query = input.trim();
    // locationbias=circle:radius@lat,lng (Pakistan center ~Islamabad, 400km radius)
    const bias = 'circle:400000@33.6844,73.0479';
    final uri = Uri.parse(
      '$_base/autocomplete/json'
      '?input=${Uri.encodeComponent(query)}'
      '&locationbias=${Uri.encodeComponent(bias)}'
      '&key=$kGoogleMapsApiKey',
    );
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );
      if (res.statusCode != 200) return [];
      final json = jsonDecode(res.body) as Map<String, dynamic>?;
      if (json == null) return [];
      final status = json['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') return [];
      final predictions = json['predictions'] as List<dynamic>?;
      if (predictions == null || predictions.isEmpty) return [];
      return predictions.map((p) {
        final map = p as Map<String, dynamic>;
        return PlacePrediction(
          placeId: map['place_id'] as String? ?? '',
          description: map['description'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Place Details (Legacy) - get lat, lng, formatted_address for a place_id.
  static Future<PlaceDetailsResult?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;
    final uri = Uri.parse(
      '$_base/details/json'
      '?place_id=${Uri.encodeComponent(placeId)}'
      '&fields=geometry,formatted_address'
      '&key=$kGoogleMapsApiKey',
    );
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>?;
      if (json == null) return null;
      final status = json['status'] as String?;
      if (status != 'OK') return null;
      final result = json['result'] as Map<String, dynamic>?;
      if (result == null) return null;
      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      final formattedAddress = result['formatted_address'] as String? ?? '';
      if (lat == null || lng == null) return null;
      return PlaceDetailsResult(
        lat: lat,
        lng: lng,
        formattedAddress: formattedAddress,
      );
    } catch (_) {
      return null;
    }
  }
}
