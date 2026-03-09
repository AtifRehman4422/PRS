import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:propertyrent/core/constants/api_config.dart';

const Duration _kListingRequestTimeout = Duration(seconds: 30);

class ListingApiResult {
  final bool success;
  final String? message;
  ListingApiResult({required this.success, this.message});
}

class ListingApi {
  static Future<Map<String, String>> _headers({required String token}) async {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create listing with images (multipart). `images` are local file paths.
  static Future<ListingApiResult> createListing({
    required String token,
    required Map<String, String> fields,
    required List<String> images,
  }) async {
    final uri = Uri.parse(listingsUrl(''));
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _headers(token: token));
    fields.forEach((k, v) {
      if (v.isNotEmpty) request.fields[k] = v;
    });

    for (final path in images) {
      if (path.isEmpty) continue;
      try {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      } catch (_) {
        // ignore bad image paths
      }
    }

    try {
      final streamed = await request.send().timeout(
        _kListingRequestTimeout,
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Response timeout'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final j = _tryJson(response.body);
        return ListingApiResult(
          success: true,
          message: j?['message'] as String? ?? 'Listing created',
        );
      }
      final j = _tryJson(response.body);
      return ListingApiResult(
        success: false,
        message: j?['message'] as String? ?? 'Failed to create listing (${response.statusCode})',
      );
    } on SocketException catch (_) {
      return ListingApiResult(
        success: false,
        message: 'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException catch (_) {
      return ListingApiResult(
        success: false,
        message: 'No internet connection. Please check your network and try again.',
      );
    } on Exception catch (e) {
      return ListingApiResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// GET /api/listings?city=&property_type=&user_id=
  static Future<List<Map<String, dynamic>>> getListings({
    String? city,
    String? propertyType,
    int? userId,
  }) async {
    try {
      final parts = <String>[];
      if (city != null && city.isNotEmpty) {
        parts.add('city=${Uri.encodeComponent(city)}');
      }
      if (propertyType != null && propertyType.isNotEmpty) {
        parts.add('property_type=${Uri.encodeComponent(propertyType)}');
      }
      if (userId != null && userId > 0) {
        parts.add('user_id=$userId');
      }
      final path = parts.isEmpty ? '' : '?${parts.join('&')}';
      final uri = Uri.parse(listingsUrl(path));
      final r = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      if (r.statusCode != 200) return [];
      final list = _parseListingsResponse(r.body);
      return list;
    } on Exception catch (_) {
      return [];
    }
  }

  /// Parses API response: either a raw array or { data: [] } / { listings: [] }.
  static List<Map<String, dynamic>> _parseListingsResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e as Map)));
      }
      if (decoded is Map<String, dynamic>) {
        final list = decoded['data'] ?? decoded['listings'];
        if (list is List) {
          return List<Map<String, dynamic>>.from(list.map((e) => Map<String, dynamic>.from(e as Map)));
        }
      }
    } catch (_) {}
    return [];
  }

  /// PATCH /api/listings/:id - Update own listing (auth, owner only). Same fields/images as create.
  /// [existingImagePaths]: paths from API to keep (edit mode); new files in [images].
  static Future<ListingApiResult> updateListing({
    required String token,
    required int listingId,
    required Map<String, String> fields,
    List<String> existingImagePaths = const [],
    required List<String> images,
  }) async {
    final uri = Uri.parse(listingsUrl('/$listingId'));
    final request = http.MultipartRequest('PATCH', uri);
    request.headers.addAll(await _headers(token: token));
    fields.forEach((k, v) {
      if (v.isNotEmpty) request.fields[k] = v;
    });
    if (existingImagePaths.isNotEmpty) {
      request.fields['existing_images'] = jsonEncode(existingImagePaths);
    }
    for (final path in images) {
      if (path.isEmpty) continue;
      try {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      } catch (_) {}
    }
    try {
      final streamed = await request.send().timeout(
        _kListingRequestTimeout,
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Response timeout'),
      );
      if (response.statusCode == 200) {
        return ListingApiResult(success: true, message: 'Listing updated successfully');
      }
      final j = _tryJson(response.body);
      return ListingApiResult(
        success: false,
        message: j?['message'] as String? ?? 'Failed to update listing (${response.statusCode})',
      );
    } on Exception catch (e) {
      return ListingApiResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// DELETE /api/listings/:id (auth, owner only)
  static Future<ListingApiResult> deleteListing({
    required String token,
    required int listingId,
  }) async {
    try {
      final uri = Uri.parse(listingsUrl('/$listingId'));
      final r = await http
          .delete(
            uri,
            headers: await _headers(token: token),
          )
          .timeout(
            _kListingRequestTimeout,
            onTimeout: () => throw TimeoutException('Connection timeout'),
          );
      if (r.statusCode == 200) {
        return ListingApiResult(success: true, message: 'Listing deleted');
      }
      final j = _tryJson(r.body);
      return ListingApiResult(
        success: false,
        message: j?['message'] as String? ?? 'Failed to delete listing (${r.statusCode})',
      );
    } on Exception catch (e) {
      return ListingApiResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// GET /api/listings/:id
  static Future<Map<String, dynamic>?> getListingById(int id) async {
    try {
      final uri = Uri.parse(listingsUrl('/$id'));
      final r = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      if (r.statusCode != 200) return null;
      return _tryJson(r.body);
    } on Exception catch (_) {
      return null;
    }
  }

  /// POST /api/listings/:id/report
  static Future<ListingApiResult> reportListing({
    required String token,
    required int listingId,
    required String reason,
    String? details,
    String? contact,
  }) async {
    try {
      final uri = Uri.parse(listingsUrl('/$listingId/report'));
      final body = <String, dynamic>{
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
        if (contact != null && contact.isNotEmpty) 'contact': contact,
      };
      final r = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(
            _kListingRequestTimeout,
            onTimeout: () => throw TimeoutException('Connection timeout'),
          );
      final j = _tryJson(r.body);
      if (r.statusCode == 201) {
        return ListingApiResult(success: true, message: j?['message'] as String? ?? 'Report submitted');
      }
      return ListingApiResult(
        success: false,
        message: j?['message'] as String? ?? 'Failed to submit report (${r.statusCode})',
      );
    } on Exception catch (e) {
      return ListingApiResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  static Map<String, dynamic>? _tryJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}

