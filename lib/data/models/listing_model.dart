import 'package:propertyrent/core/constants/api_config.dart';

/// Listing from API (list or single with type_details/extras).
class ListingModel {
  const ListingModel({
    required this.id,
    this.userId,
    required this.propertyType,
    required this.city,
    required this.title,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.areaSize,
    this.areaUnit,
    this.rent,
    this.advanceAmount,
    this.securityDeposit,
    this.isNegotiable = false,
    this.availableFrom,
    this.availableFromTime,
    this.contactEmail,
    this.contactPhone,
    this.ownerName,
    this.whatsapp,
    this.sector,
    this.landmark,
    this.status,
    this.createdAt,
    this.username,
    this.email,
    this.images = const [],
    this.typeDetails,
    this.extras,
  });

  final int id;
  final int? userId;
  final String propertyType;
  final String city;
  final String title;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final double? areaSize;
  final String? areaUnit;
  final double? rent;
  final double? advanceAmount;
  final double? securityDeposit;
  final bool isNegotiable;
  final String? availableFrom;
  final String? availableFromTime;
  final String? contactEmail;
  final String? contactPhone;
  final String? ownerName;
  final String? whatsapp;
  final String? sector;
  final String? landmark;
  final String? status;
  final String? createdAt;
  final String? username;
  final String? email;
  final List<String> images;
  final Map<String, dynamic>? typeDetails;
  final Map<String, dynamic>? extras;

  String get price => rent != null ? rent!.toStringAsFixed(0) : '0';
  String get location => city;
  String get subLocation => address ?? sector ?? landmark ?? '';

  int get bedrooms {
    final r = extras?['rooms'];
    if (r == null) return 0;
    if (r is int) return r;
    return int.tryParse(r.toString()) ?? 0;
  }

  int get bathrooms {
    final r = extras?['bathrooms'];
    if (r == null) return 0;
    if (r is int) return r;
    return int.tryParse(r.toString()) ?? 0;
  }

  List<String> get imageUrls =>
      images.map((p) => p.startsWith('http') ? p : uploadsUrl('/$p')).toList();

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String? _toString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  factory ListingModel.fromJson(Map<String, dynamic> j) {
    final imgList = j['images'];
    List<String> imgs = [];
    if (imgList is List) {
      for (final e in imgList) {
        if (e != null) imgs.add(e.toString());
      }
    }
    return ListingModel(
      id: _toInt(j['id']),
      userId: _toInt(j['user_id'], fallback: 0) == 0 ? null : _toInt(j['user_id']),
      propertyType: _toString(j['property_type']) ?? '',
      city: _toString(j['city']) ?? '',
      title: _toString(j['title']) ?? '',
      address: _toString(j['address']),
      latitude: _toDouble(j['latitude']),
      longitude: _toDouble(j['longitude']),
      description: _toString(j['description']),
      areaSize: _toDouble(j['area_size']),
      areaUnit: _toString(j['area_unit']),
      rent: _toDouble(j['rent']),
      advanceAmount: _toDouble(j['advance_amount']),
      securityDeposit: _toDouble(j['security_deposit']),
      isNegotiable: j['is_negotiable'] == true,
      availableFrom: _toString(j['available_from']),
      availableFromTime: _toString(j['available_from_time']),
      contactEmail: _toString(j['contact_email']),
      contactPhone: _toString(j['contact_phone']),
      ownerName: _toString(j['owner_name']),
      whatsapp: _toString(j['whatsapp']),
      sector: _toString(j['sector']),
      landmark: _toString(j['landmark']),
      status: _toString(j['status']),
      createdAt: _toString(j['created_at']),
      username: _toString(j['username']),
      email: _toString(j['email']),
      images: imgs,
      typeDetails: j['type_details'] is Map ? Map<String, dynamic>.from(j['type_details'] as Map) : null,
      extras: j['extras'] is Map ? Map<String, dynamic>.from(j['extras'] as Map) : null,
    );
  }

  Map<String, dynamic> toCardMap() => {
        'id': id,
        'title': title,
        'location': location,
        'subLocation': subLocation,
        'price': price,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'images': imageUrls.isEmpty ? [] : imageUrls,
      };
}
