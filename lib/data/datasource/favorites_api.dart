import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:propertyrent/core/constants/api_config.dart';

const Duration _kTimeout = Duration(seconds: 15);

class FavoritesApi {
  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// POST /api/favorites body: listing_id
  static Future<bool> add(String token, int listingId) async {
    try {
      final uri = Uri.parse(favoritesUrl(''));
      final r = await http
          .post(
            uri,
            headers: _headers(token),
            body: jsonEncode({'listing_id': listingId}),
          )
          .timeout(_kTimeout, onTimeout: () => throw TimeoutException('Timeout'));
      return r.statusCode == 201 || r.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/favorites/:listingId
  static Future<bool> remove(String token, int listingId) async {
    try {
      final uri = Uri.parse(favoritesUrl('/$listingId'));
      final r = await http
          .delete(uri, headers: _headers(token))
          .timeout(_kTimeout, onTimeout: () => throw TimeoutException('Timeout'));
      return r.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// GET /api/favorites - list of listings (with images)
  static Future<List<Map<String, dynamic>>> list(String token) async {
    try {
      final uri = Uri.parse(favoritesUrl(''));
      final r = await http
          .get(uri, headers: _headers(token))
          .timeout(_kTimeout, onTimeout: () => throw TimeoutException('Timeout'));
      if (r.statusCode != 200) return [];
      final decoded = jsonDecode(r.body);
      if (decoded is! List) return [];
      return List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e as Map)));
    } on Exception catch (_) {
      return [];
    }
  }

  /// GET /api/favorites/check/:listingId
  static Future<bool> check(String token, int listingId) async {
    try {
      final uri = Uri.parse(favoritesUrl('/check/$listingId'));
      final r = await http
          .get(uri, headers: _headers(token))
          .timeout(_kTimeout, onTimeout: () => throw TimeoutException('Timeout'));
      if (r.statusCode != 200) return false;
      final j = jsonDecode(r.body) as Map<String, dynamic>?;
      return j?['is_favorite'] == true;
    } on Exception catch (_) {
      return false;
    }
  }
}
