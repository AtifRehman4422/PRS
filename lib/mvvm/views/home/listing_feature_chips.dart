import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/data/models/listing_model.dart';

/// Chip with icon + DB value (Hostel type, Beds, Room type).
Widget buildImportantFeatureChip(
  BuildContext context,
  IconData icon,
  String value, {
  Color? iconColor,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final color = iconColor ?? AppColors.primary;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.9),
          ),
        ),
      ],
    ),
  );
}

String _valueFromTd(Map<String, dynamic> td, String key) {
  final v = td[key];
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}

/// Exactly 3 features for card:
/// - Hostel: hostel_type, beds, room_type (from DB)
/// - Others: beds, baths + type-specific (BHK / rooms, etc.)
List<Widget> buildThreeFeatureChips(BuildContext context, ListingModel listing) {
  final td = listing.typeDetails ?? {};
  final chips = <Widget>[];

  if (listing.propertyType == 'Hostel') {
    final hostelType = _valueFromTd(td, 'hostel_type');
    if (hostelType != '—') {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.home_work_outlined,
        hostelType,
        iconColor: AppColors.primary,
      ));
    }
    final bedsVal = td['beds'] ?? td['Beds'];
    final bedsStr = (bedsVal != null && bedsVal.toString().trim().isNotEmpty)
        ? bedsVal.toString().trim()
        : '—';
    chips.add(buildImportantFeatureChip(
      context,
      Icons.single_bed,
      bedsStr,
      iconColor: AppColors.primary,
    ));
    final roomType = _valueFromTd(td, 'room_type');
    if (roomType != '—') {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.meeting_room,
        roomType,
        iconColor: AppColors.primary,
      ));
    }
  } else {
    if (listing.bedrooms > 0) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.bed_outlined,
        '${listing.bedrooms} Beds',
        iconColor: AppColors.primary,
      ));
    }
    if (listing.bathrooms > 0 && chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.bathtub_outlined,
        '${listing.bathrooms} Baths',
        iconColor: AppColors.primary,
      ));
    }
    if ((listing.propertyType == 'House' || listing.propertyType == 'Flat') &&
        td['bhk'] != null &&
        chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.door_front_door,
        '${td['bhk']} BHK',
        iconColor: AppColors.primary,
      ));
    } else if ((listing.propertyType == 'Guest House' ||
            listing.propertyType == 'Hotel') &&
        td['rooms'] != null &&
        chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.meeting_room,
        '${td['rooms']} Rooms',
        iconColor: AppColors.primary,
      ));
    } else if (listing.propertyType == 'Shop' && chips.length < 3) {
      final shopLoc = _valueFromTd(td, 'shop_location');
      if (shopLoc != '—') {
        chips.add(buildImportantFeatureChip(
          context,
          Icons.store,
          shopLoc,
          iconColor: AppColors.primary,
        ));
      }
    } else if (listing.propertyType == 'Office' &&
        td['cabins'] != null &&
        chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.meeting_room,
        '${td['cabins']} Cabins',
        iconColor: AppColors.primary,
      ));
    } else if (listing.propertyType == 'Marquee' &&
        td['max_guests'] != null &&
        chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.groups,
        '${td['max_guests']} Guests',
        iconColor: AppColors.primary,
      ));
    } else if (listing.propertyType == 'Farm House' &&
        td['land_size'] != null &&
        chips.length < 3) {
      chips.add(buildImportantFeatureChip(
        context,
        Icons.park,
        '${td['land_size']} Land',
        iconColor: AppColors.primary,
      ));
    }
  }
  return chips.take(3).toList();
}

