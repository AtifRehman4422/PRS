import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/api_config.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/core/widgets/app_primary_button.dart';
import 'package:propertyrent/core/widgets/logo_loader.dart';
import 'package:propertyrent/data/datasource/listing_api.dart';
import 'package:propertyrent/data/models/listing_model.dart';
import 'package:propertyrent/mvvm/views/home/search_city_view.dart';
import 'package:propertyrent/mvvm/views/add/map_location_picker.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/auth/login_view.dart';

class AddView extends ConsumerStatefulWidget {
  /// If set, opens in edit mode: loads listing and saves via update API.
  final int? listingId;

  const AddView({super.key, this.listingId});

  @override
  ConsumerState<AddView> createState() => _AddViewState();
}

class _AddViewState extends ConsumerState<AddView> {
  final _formKey = GlobalKey<FormState>();

  // Property Type
  String _selectedPropertyType = 'Hostel';
  final List<String> _propertyTypes = [
    'Hostel',
    'Hotel',
    'House',
    'Flat',
    'Office',
    'Shop',
  ];

  // Hostel specific
  String _selectedHostelType = 'Boys';
  // ignore: unused_field - reserved for hostel type chips UI
  final List<String> _hostelTypes = ['Boys', 'Girls', 'Co-living'];
  int _selectedBeds = 1;
  String _hostelRoomType = 'Single';
  final List<String> _hostelRoomTypes = ['Single', 'Double', 'Triple'];
  bool _hostelAttachedWashroom = false;
  bool _hostelAc = false;
  bool _hostelStudyTable = false;
  bool _hostelWifi = false;
  bool _hostelLaundry = false;
  bool _hostelWater24 = false;
  bool _hostelPowerBackup = false;
  bool _hostelSecurity = false;
  bool _hostelFoodIncluded = false;
  String _hostelPreference = 'Students';
  final List<String> _hostelPreferences = [
    'Students',
    'Working Professionals',
    'Both',
  ];
  bool _hostelSmokingAllowed = false;
  bool _hostelAlcoholAllowed = false;
  // ignore: unused_field - reserved for hostel in-time rules UI
  final String _hostelInTimeRules = 'No restriction';
  final _hostelAvailableFromController = TextEditingController();

  // House/Flat specific
  String _selectedPortion = 'Full House';
  final List<String> _portions = [
    'Full House',
    'Upper Portion',
    'Lower Portion',
  ];
  String _selectedBHK = '1BHK';
  final List<String> _bhkTypes = ['1BHK', '2BHK', '3BHK', '4BHK', 'Villa'];
  int _selectedFloor = 1;
  String _houseFurnished = 'Unfurnished';
  final List<String> _furnishedOptions = [
    'Furnished',
    'Semi-Furnished',
    'Unfurnished',
  ];
  bool _houseBalcony = false;
  bool _houseModularKitchen = false;
  bool _houseLift = false;
  bool _houseParking = false;
  bool _houseWater24 = false;
  bool _housePowerBackup = false;
  bool _houseSecurity = false;
  bool _houseGatedSociety = false;
  String _housePreference = 'Family';
  final List<String> _housePreferences = ['Family', 'Bachelor', 'Both'];
  bool _housePetsAllowed = false;
  bool _houseVegNonVeg = false;
  final _houseAvailableFromController = TextEditingController();

  // Flat specific improvements
  bool _flatLift = false;
  bool _flatBalcony = false;
  String _flatFurnished = 'Unfurnished';
  bool _flatGenerator = false;
  bool _flatParking = false;
  bool _flatModularKitchen = false;
  bool _flatWater24 = false;
  bool _flatSecurity = false;
  bool _flatGatedSociety = false;

  // Shop specific
  String _shopLocation = 'Main Road';
  final List<String> _shopLocations = ['Main Road', 'Inside Market'];
  double _shopFrontWidth = 0;
  double _shopCeilingHeight = 0;
  String _shopFrontType = 'Shutter';
  final List<String> _shopFrontTypes = ['Shutter', 'Glass Front'];
  bool _shopElectricity = false;
  bool _shopWater = false;
  bool _shopWashroom = false;
  bool _shopParking = false;
  String _shopSuitableFor = 'General';
  final List<String> _shopSuitableOptions = [
    'Medical',
    'Grocery',
    'Salon',
    'Showroom',
    'General',
  ];
  final _shopAvailableFromController = TextEditingController();

  // Office specific
  int _selectedOfficeFloor = 1;
  String _officeFurnished = 'Unfurnished';
  int _officeCabins = 0;
  int _officeWorkstations = 0;
  bool _officeConferenceRoom = false;
  bool _officeReception = false;
  bool _officeLift = false;
  bool _officeParking = false;
  bool _officePowerBackup = false;
  bool _officeInternetReady = false;
  bool _officeSecurity = false;
  String _officeSuitableFor = 'IT Company';
  final List<String> _officeSuitableOptions = [
    'IT Company',
    'Startup',
    'Consultancy',
    'General',
  ];
  final _officeAvailableFromController = TextEditingController();

  // Hotel specific
  int _hotelRooms = 1;
  String _hotelAcType = 'AC';
  final List<String> _hotelAcOptions = ['AC', 'Non-AC', 'Both'];
  bool _hotelCleanBeds = false;
  bool _hotelAttachedBathroom = false;
  bool _hotelFamilyRooms = false;
  bool _hotelWifi = false;
  bool _hotelParking = false;
  bool _hotelBreakfast = false;
  bool _hotelLunchDinner = false;
  bool _hotelRoomService = false;
  bool _hotelCctv = false;
  bool _hotelSecurity24 = false;
  bool _hotelSafeEnv = false;
  bool _hotelNearMarket = false;
  bool _hotelNearBusStand = false;
  bool _hotelNearTourist = false;
  bool _hotelLaundry = false;
  bool _hotelSwimmingPool = false;
  bool _hotelGym = false;
  bool _hotelConferenceHall = false;
  final _hotelAvailableFromController = TextEditingController();

  // Marquee/Banquet specific
  int _maxGuests = 100;
  bool _marqueeAc = false;
  bool _marqueeStage = false;
  bool _marqueeBridalRoom = false;
  int _marqueeParkingCapacity = 0;
  bool _marqueeGenerator = false;
  bool _marqueeDecoration = false;
  String _marqueeCatering = 'In-house';
  final List<String> _marqueeCateringOptions = [
    'In-house',
    'Outside Allowed',
    'Both',
  ];
  String _marqueeSuitableFor = 'Wedding';
  final List<String> _marqueeSuitableOptions = [
    'Wedding',
    'Party',
    'Corporate Events',
    'All',
  ];

  // Guest House specific
  int _guestHouseRooms = 1;
  bool _guestHouseAc = false;
  bool _guestHouseAttachedBathroom = false;
  bool _guestHouseTv = false;
  bool _guestHouseWifi = false;
  bool _guestHouseRoomService = false;
  bool _guestHouseParking = false;
  bool _guestHousePowerBackup = false;
  String _guestHousePreference = 'Family';
  final List<String> _guestHousePreferences = ['Family', 'Corporate', 'Both'];
  final _guestHouseAvailableFromController = TextEditingController();

  // Farm House specific
  double _farmLandSize = 0;
  bool _farmLawn = false;
  bool _farmGarden = false;
  bool _farmRooms = false;
  bool _farmHall = false;
  bool _farmSwimmingPool = false;
  bool _farmParking = false;
  bool _farmElectricity = false;
  bool _farmWaterSupply = false;
  String _farmSuitableFor = 'Picnic';
  final List<String> _farmSuitableOptions = [
    'Picnic',
    'Party',
    'Events',
    'All',
  ];
  final _farmAvailableFromController = TextEditingController();

  // Common fields - using int for sliders
  int _selectedRoom = 1;
  int _selectedBathroom = 1;
  int _selectedKitchen = 1;
  int _selectedTVLounge = 1;
  String _selectedLaundry = 'No';
  String _selectedMess = 'No';
  String _selectedAreaUnit = 'Sq.Ft.';
  final List<String> _areaUnits = [
    'Sq.Ft.',
    'Sq.M.',
    'Sq.Yd.',
    'Marla',
    'Kanal',
  ];

  // Add page only - independent from Home page search city
  String _addPageSelectedCity = '';
  String _addPageSelectedCityForApi = '';
  String? _selectedLocationAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;
  // ignore: unused_field - reserved for time slot filter
  final String _selectedTimeSlot = 'Day';
  bool _isNegotiable = false;

  bool get _isEventProperty =>
      ['Marquee', 'Guest House', 'Farm House'].contains(_selectedPropertyType);

  // ignore: unused_field - amenities for event properties (future use)
  final Map<String, bool> _amenities = {
    'Catering available': false,
    'AC': false,
    'Parking': false,
    'Generator / Backup': false,
    'Bridal room': false,
    'Rooms for stay': false,
    'Decoration available': false,
    'Sound system': false,
    'Security': false,
  };

  // Controllers
  final _sectorController = TextEditingController();
  final _mapPinController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _rentPerDayController = TextEditingController();
  final _rentPerEventController = TextEditingController();
  final _advanceController = TextEditingController();
  final _discountController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _securityController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _areaController = TextEditingController();
  final _rentController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _availableFromTimeController = TextEditingController();
  final _hostelInTimeRulesController = TextEditingController();
  final _shopFrontWidthController = TextEditingController();
  final _shopCeilingHeightController = TextEditingController();
  final _farmLandSizeController = TextEditingController();

  final List<String> _selectedImages = [];
  /// In edit mode: image paths from API (to show and optionally keep).
  List<String> _existingImagePaths = [];
  /// Indices into _existingImagePaths that user removed (so we don't re-send them).
  final Set<int> _removedExistingIndices = {};
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 6; // Min 1 & max 6 per guideline

  bool _isSaving = false;
  bool _editLoadComplete = false;

  bool get _isEditMode => widget.listingId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadForEdit());
    }
    final user = ref.read(currentAuthUserProvider);
    if (user != null) {
      if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }
      final contact = user.phoneNumber ?? '';
      if (contact.isNotEmpty) {
        _phoneController.text = contact;
        _whatsappController.text = contact;
      }
      final displayName = user.displayName ?? '';
      if (displayName.isNotEmpty) {
        _ownerNameController.text = displayName;
      }
    }
  }

  void _addImage(String path) {
    if (_totalImageCount >= _maxImages) return;
    setState(() {
      _selectedImages.add(path);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image added (${_selectedImages.length}/$_maxImages)'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Gallery: pick one or multiple images (min 1, max 6 total).
  Future<void> _pickFromGallery() async {
    try {
      final remaining = _maxImages - _totalImageCount;
      if (remaining <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum $_maxImages images allowed'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final files = await _picker.pickMultiImage();
      if (files.isNotEmpty && mounted) {
        final toAdd = files.take(remaining).map((x) => x.path).toList();
        setState(() {
          for (final path in toAdd) {
            if (_totalImageCount < _maxImages) _selectedImages.add(path);
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${toAdd.length} image(s) added (${_selectedImages.length}/$_maxImages)'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Camera: take one photo and add it. Shows in Selected Images above Save.
  Future<void> _pickFromCamera() async {
    try {
      if (_totalImageCount >= _maxImages) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum $_maxImages images allowed'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        _addImage(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = picked.toLocal().toString().split(' ').first;
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  static bool _toBool(dynamic v) =>
      v == true || v == 'true' || v == 1 || v == '1';

  Future<void> _loadForEdit() async {
    if (widget.listingId == null) return;
    final map = await ListingApi.getListingById(widget.listingId!);
    if (map == null || !mounted) return;
    final listing = ListingModel.fromJson(map);
    final td = listing.typeDetails ?? {};
    final ext = listing.extras ?? {};
    setState(() {
      _selectedPropertyType = listing.propertyType;
      _titleController.text = listing.title;
      _descriptionController.text = listing.description ?? '';
      _areaController.text = listing.areaSize?.toString() ?? '';
      _rentController.text = listing.rent != null ? listing.rent!.toStringAsFixed(0) : '';
      _advanceController.text = listing.advanceAmount != null ? listing.advanceAmount!.toStringAsFixed(0) : '';
      _securityController.text = listing.securityDeposit != null ? listing.securityDeposit!.toStringAsFixed(0) : '';
      _isNegotiable = listing.isNegotiable;
      _emailController.text = listing.contactEmail ?? '';
      _phoneController.text = listing.contactPhone ?? '';
      _ownerNameController.text = listing.ownerName ?? '';
      _whatsappController.text = listing.whatsapp ?? '';
      _sectorController.text = listing.sector ?? '';
      _landmarkController.text = listing.landmark ?? '';
      _addPageSelectedCity = listing.city;
      _addPageSelectedCityForApi = listing.city;
      _selectedLatitude = listing.latitude;
      _selectedLongitude = listing.longitude;
      _selectedLocationAddress = listing.address;
      _selectedRoom = int.tryParse(ext['rooms']?.toString() ?? '') ?? 0;
      _selectedBathroom = int.tryParse(ext['bathrooms']?.toString() ?? '') ?? 0;
      _selectedKitchen = int.tryParse(ext['kitchen']?.toString() ?? '') ?? 0;
      _selectedTVLounge = int.tryParse(ext['tv_lounge']?.toString() ?? '') ?? 0;
      _selectedLaundry = _normYesNo(ext['laundry']?.toString());
      _selectedMess = _normYesNo(ext['mess']?.toString());
      if (listing.propertyType == 'Hostel') {
        _selectedHostelType = td['hostel_type']?.toString() ?? 'Boys';
        _selectedBeds = int.tryParse(td['beds']?.toString() ?? '') ?? 1;
        _hostelRoomType = td['room_type']?.toString() ?? 'Single';
        _hostelAvailableFromController.text = td['available_from_date']?.toString() ?? '';
        _hostelAttachedWashroom = _toBool(td['attached_washroom']);
        _hostelAc = _toBool(td['ac']);
        _hostelStudyTable = _toBool(td['study_table']);
        _hostelWifi = _toBool(td['wifi']);
        _hostelLaundry = _toBool(td['laundry']);
        _hostelWater24 = _toBool(td['water_24']);
        _hostelPowerBackup = _toBool(td['power_backup']);
        _hostelSecurity = _toBool(td['security']);
        _hostelFoodIncluded = _toBool(td['food_included']);
        _hostelPreference = td['preference']?.toString() ?? 'Students';
        _hostelSmokingAllowed = _toBool(td['smoking_allowed']);
        _hostelAlcoholAllowed = _toBool(td['alcohol_allowed']);
        _hostelInTimeRulesController.text = td['in_time_rules']?.toString() ?? '';
      } else if (listing.propertyType == 'House') {
        _selectedPortion = td['portion']?.toString() ?? 'Full House';
        _selectedBHK = td['bhk']?.toString() ?? '1BHK';
        _selectedFloor = int.tryParse(td['floor']?.toString() ?? '') ?? 1;
        _houseFurnished = td['furnished']?.toString() ?? 'Unfurnished';
        _houseAvailableFromController.text = td['available_from_date']?.toString() ?? '';
        _houseBalcony = _toBool(td['balcony']);
        _houseModularKitchen = _toBool(td['modular_kitchen']);
        _houseLift = _toBool(td['lift']);
        _houseParking = _toBool(td['parking']);
        _houseWater24 = _toBool(td['water_24']);
        _housePowerBackup = _toBool(td['power_backup']);
        _houseSecurity = _toBool(td['security']);
        _houseGatedSociety = _toBool(td['gated_society']);
        _housePreference = td['preference']?.toString() ?? 'Family';
        _housePetsAllowed = _toBool(td['pets_allowed']);
        _houseVegNonVeg = _toBool(td['veg_non_veg']);
      } else if (listing.propertyType == 'Flat') {
        _selectedPortion = td['portion']?.toString() ?? 'Full House';
        _selectedBHK = td['bhk']?.toString() ?? '1BHK';
        _selectedFloor = int.tryParse(td['floor']?.toString() ?? '') ?? 1;
        _houseFurnished = td['furnished']?.toString() ?? 'Unfurnished';
        _houseAvailableFromController.text = td['available_from_date']?.toString() ?? '';
        _flatLift = _toBool(td['lift']);
        _flatBalcony = _toBool(td['balcony']);
        _flatFurnished = td['furnished']?.toString() ?? 'Unfurnished';
        _flatGenerator = _toBool(td['generator']);
        _flatParking = _toBool(td['parking']);
        _flatModularKitchen = _toBool(td['modular_kitchen']);
        _flatWater24 = _toBool(td['water_24']);
        _flatSecurity = _toBool(td['security']);
        _flatGatedSociety = _toBool(td['gated_society']);
      } else if (listing.propertyType == 'Shop') {
        _shopLocation = td['shop_location']?.toString() ?? 'Main Road';
        _shopFrontWidth = (double.tryParse(td['front_width']?.toString() ?? '') ?? 0);
        _shopCeilingHeight = (double.tryParse(td['ceiling_height']?.toString() ?? '') ?? 0);
        _shopFrontType = td['front_type']?.toString() ?? 'Shutter';
        _shopElectricity = _toBool(td['electricity']);
        _shopWater = _toBool(td['water']);
        _shopWashroom = _toBool(td['washroom']);
        _shopParking = _toBool(td['parking']);
        _shopSuitableFor = td['suitable_for']?.toString() ?? 'General';
        _shopAvailableFromController.text = td['available_from_date']?.toString() ?? '';
      } else if (listing.propertyType == 'Office') {
        _selectedOfficeFloor = int.tryParse(td['floor']?.toString() ?? '') ?? 1;
        _officeFurnished = td['furnished']?.toString() ?? 'Unfurnished';
        _officeCabins = int.tryParse(td['cabins']?.toString() ?? '') ?? 0;
        _officeWorkstations = int.tryParse(td['workstations']?.toString() ?? '') ?? 0;
        _officeConferenceRoom = _toBool(td['conference_room']);
        _officeReception = _toBool(td['reception']);
        _officeLift = _toBool(td['lift']);
        _officeParking = _toBool(td['parking']);
        _officePowerBackup = _toBool(td['power_backup']);
        _officeInternetReady = _toBool(td['internet_ready']);
        _officeSecurity = _toBool(td['security']);
        _officeSuitableFor = td['suitable_for']?.toString() ?? 'IT Company';
        _officeAvailableFromController.text = td['available_from_date']?.toString() ?? '';
      } else if (listing.propertyType == 'Hotel') {
        _hotelRooms = int.tryParse(td['rooms']?.toString() ?? '') ?? 1;
        _hotelAcType = td['ac_type']?.toString() ?? 'AC';
        _hotelCleanBeds = _toBool(td['clean_beds']);
        _hotelAttachedBathroom = _toBool(td['attached_bathroom']);
        _hotelFamilyRooms = _toBool(td['family_rooms']);
        _hotelWifi = _toBool(td['wifi']);
        _hotelParking = _toBool(td['parking']);
        _hotelBreakfast = _toBool(td['breakfast']);
        _hotelLunchDinner = _toBool(td['lunch_dinner']);
        _hotelRoomService = _toBool(td['room_service']);
        _hotelCctv = _toBool(td['cctv']);
        _hotelSecurity24 = _toBool(td['security_24']);
        _hotelSafeEnv = _toBool(td['safe_env']);
        _hotelNearMarket = _toBool(td['near_market']);
        _hotelNearBusStand = _toBool(td['near_bus_stand']);
        _hotelNearTourist = _toBool(td['near_tourist']);
        _hotelLaundry = _toBool(td['laundry']);
        _hotelSwimmingPool = _toBool(td['swimming_pool']);
        _hotelGym = _toBool(td['gym']);
        _hotelConferenceHall = _toBool(td['conference_hall']);
        _hotelAvailableFromController.text = td['available_from_date']?.toString() ?? '';
      } else if (listing.propertyType == 'Marquee') {
        _maxGuests = int.tryParse(td['max_guests']?.toString() ?? '') ?? 100;
        _marqueeAc = _toBool(td['ac']);
        _marqueeStage = _toBool(td['stage']);
        _marqueeBridalRoom = _toBool(td['bridal_room']);
        _marqueeParkingCapacity = int.tryParse(td['parking_capacity']?.toString() ?? '') ?? 0;
        _marqueeGenerator = _toBool(td['generator']);
        _marqueeDecoration = _toBool(td['decoration']);
        _marqueeCatering = td['catering']?.toString() ?? 'In-house';
        _marqueeSuitableFor = td['suitable_for']?.toString() ?? 'Wedding';
        _rentPerDayController.text = td['rent_per_day']?.toString() ?? '';
        _rentPerEventController.text = td['rent_per_event']?.toString() ?? '';
        _advanceController.text = td['advance_amount']?.toString() ?? '';
        _discountController.text = td['discount']?.toString() ?? '';
        _maintenanceController.text = td['maintenance']?.toString() ?? '';
        _securityController.text = td['security_deposit']?.toString() ?? '';
      } else if (listing.propertyType == 'Guest House') {
        _guestHouseRooms = int.tryParse(td['rooms']?.toString() ?? '') ?? 1;
        _guestHouseAc = _toBool(td['ac']);
        _guestHouseAttachedBathroom = _toBool(td['attached_bathroom']);
        _guestHouseTv = _toBool(td['tv']);
        _guestHouseWifi = _toBool(td['wifi']);
        _guestHouseRoomService = _toBool(td['room_service']);
        _guestHouseParking = _toBool(td['parking']);
        _guestHousePowerBackup = _toBool(td['power_backup']);
        _guestHousePreference = td['preference']?.toString() ?? 'Family';
        _guestHouseAvailableFromController.text = td['available_from_date']?.toString() ?? '';
      } else if (listing.propertyType == 'Farm House') {
        _farmLandSize = double.tryParse(td['land_size']?.toString() ?? '') ?? 0;
        _farmLawn = _toBool(td['lawn']);
        _farmGarden = _toBool(td['garden']);
        _farmRooms = _toBool(td['rooms']);
        _farmHall = _toBool(td['hall']);
        _farmSwimmingPool = _toBool(td['swimming_pool']);
        _farmParking = _toBool(td['parking']);
        _farmElectricity = _toBool(td['electricity']);
        _farmWaterSupply = _toBool(td['water_supply']);
        _farmSuitableFor = td['suitable_for']?.toString() ?? 'Picnic';
        _farmAvailableFromController.text = td['available_from_date']?.toString() ?? '';
        _farmLandSizeController.text = td['land_size']?.toString() ?? '';
      }
      _availableFromTimeController.text = listing.availableFromTime ?? '';
      _existingImagePaths = List<String>.from(listing.images);
      _editLoadComplete = true;
    });
  }

  static String _normYesNo(String? v) {
    if (v == null) return 'No';
    final s = v.trim().toLowerCase();
    if (s == 'yes' || s == 'true' || s == '1') return 'Yes';
    return 'No';
  }

  /// Count of existing images still shown (not removed).
  int get _existingKeptCount =>
      _existingImagePaths.length - _removedExistingIndices.length;
  /// Total images (existing kept + new) for limit check.
  int get _totalImageCount => _existingKeptCount + _selectedImages.length;

  void _removeExistingImageAt(int index) {
    if (index < 0 || index >= _existingImagePaths.length) return;
    setState(() => _removedExistingIndices.add(index));
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors in the form'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final totalImages = _isEditMode ? _totalImageCount : _selectedImages.length;
    if (totalImages < 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least 1 image (Camera or Gallery)'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (_addPageSelectedCity.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select city'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) {
      return;
    }
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final token = await authRepo.getAuthToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() => _isSaving = false);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const LoginView(),
          );
        }
        return;
      }

      final propertyType = _selectedPropertyType;
      String? typeAvailableDate;

      switch (propertyType) {
        case 'Hostel':
          typeAvailableDate = _hostelAvailableFromController.text.trim();
          break;
        case 'House':
        case 'Flat':
          typeAvailableDate = _houseAvailableFromController.text.trim();
          break;
        case 'Shop':
          typeAvailableDate = _shopAvailableFromController.text.trim();
          break;
        case 'Office':
          typeAvailableDate = _officeAvailableFromController.text.trim();
          break;
        case 'Hotel':
          typeAvailableDate = _hotelAvailableFromController.text.trim();
          break;
        case 'Guest House':
          typeAvailableDate = _guestHouseAvailableFromController.text.trim();
          break;
        case 'Farm House':
          typeAvailableDate = _farmAvailableFromController.text.trim();
          break;
      }

      final Map<String, dynamic> typeDetails = {};

      if (propertyType == 'Hostel') {
        typeDetails.addAll({
          'hostel_type': _selectedHostelType,
          'beds': _selectedBeds,
          'room_type': _hostelRoomType,
          'attached_washroom': _hostelAttachedWashroom,
          'ac': _hostelAc,
          'study_table': _hostelStudyTable,
          'wifi': _hostelWifi,
          'laundry': _hostelLaundry,
          'water_24': _hostelWater24,
          'power_backup': _hostelPowerBackup,
          'security': _hostelSecurity,
          'food_included': _hostelFoodIncluded,
          'preference': _hostelPreference,
          'smoking_allowed': _hostelSmokingAllowed,
          'alcohol_allowed': _hostelAlcoholAllowed,
          'in_time_rules': _hostelInTimeRulesController.text.trim(),
          'available_from_date': typeAvailableDate,
        });
      } else if (propertyType == 'House' || propertyType == 'Flat') {
        final isHouse = propertyType == 'House';
        if (isHouse) {
          typeDetails.addAll({
            'portion': _selectedPortion,
            'bhk': null,
            'floor': null,
            'furnished': _houseFurnished,
            'balcony': _houseBalcony,
            'modular_kitchen': _houseModularKitchen,
            'lift': _houseLift,
            'parking': _houseParking,
            'water_24': _houseWater24,
            'power_backup': _housePowerBackup,
            'security': _houseSecurity,
            'gated_society': _houseGatedSociety,
            'preference': _housePreference,
            'pets_allowed': _housePetsAllowed,
            'veg_non_veg': _houseVegNonVeg,
            'available_from_date': typeAvailableDate,
          });
        } else {
          typeDetails.addAll({
            'portion': null,
            'bhk': _selectedBHK,
            'floor': _selectedFloor,
            'furnished': _flatFurnished,
            'balcony': _flatBalcony,
            'lift': _flatLift,
            'modular_kitchen': _flatModularKitchen,
            'parking': _flatParking,
            'water_24': _flatWater24,
            'power_backup': null,
            'security': _flatSecurity,
            'gated_society': _flatGatedSociety,
            'preference': _housePreference,
            'pets_allowed': _housePetsAllowed,
            'veg_non_veg': _houseVegNonVeg,
            'available_from_date': typeAvailableDate,
          });
        }
      } else if (propertyType == 'Shop') {
        typeDetails.addAll({
          'shop_location': _shopLocation,
          'front_width': _shopFrontWidth.toString(),
          'ceiling_height': _shopCeilingHeight.toString(),
          'front_type': _shopFrontType,
          'electricity': _shopElectricity,
          'water': _shopWater,
          'washroom': _shopWashroom,
          'parking': _shopParking,
          'suitable_for': _shopSuitableFor,
          'available_from_date': typeAvailableDate,
        });
      } else if (propertyType == 'Office') {
        typeDetails.addAll({
          'floor': _selectedOfficeFloor,
          'furnished': _officeFurnished,
          'cabins': _officeCabins,
          'workstations': _officeWorkstations,
          'conference_room': _officeConferenceRoom,
          'reception': _officeReception,
          'lift': _officeLift,
          'parking': _officeParking,
          'power_backup': _officePowerBackup,
          'internet_ready': _officeInternetReady,
          'security': _officeSecurity,
          'suitable_for': _officeSuitableFor,
          'available_from_date': typeAvailableDate,
        });
      } else if (propertyType == 'Hotel') {
        typeDetails.addAll({
          'rooms': _hotelRooms,
          'ac_type': _hotelAcType,
          'clean_beds': _hotelCleanBeds,
          'attached_bathroom': _hotelAttachedBathroom,
          'family_rooms': _hotelFamilyRooms,
          'wifi': _hotelWifi,
          'parking': _hotelParking,
          'breakfast': _hotelBreakfast,
          'lunch_dinner': _hotelLunchDinner,
          'room_service': _hotelRoomService,
          'cctv': _hotelCctv,
          'security_24': _hotelSecurity24,
          'safe_env': _hotelSafeEnv,
          'near_market': _hotelNearMarket,
          'near_bus_stand': _hotelNearBusStand,
          'near_tourist': _hotelNearTourist,
          'laundry': _hotelLaundry,
          'swimming_pool': _hotelSwimmingPool,
          'gym': _hotelGym,
          'conference_hall': _hotelConferenceHall,
          'available_from_date': typeAvailableDate,
        });
      } else if (propertyType == 'Marquee') {
        typeDetails.addAll({
          'max_guests': _maxGuests,
          'ac': _marqueeAc,
          'stage': _marqueeStage,
          'bridal_room': _marqueeBridalRoom,
          'parking_capacity': _marqueeParkingCapacity,
          'generator': _marqueeGenerator,
          'decoration': _marqueeDecoration,
          'catering': _marqueeCatering,
          'suitable_for': _marqueeSuitableFor,
          'rent_per_day': _rentPerDayController.text.trim(),
          'rent_per_event': _rentPerEventController.text.trim(),
          'advance_amount': _advanceController.text.trim(),
          'discount': _discountController.text.trim(),
          'maintenance': _maintenanceController.text.trim(),
          'security_deposit': _securityController.text.trim(),
        });
      } else if (propertyType == 'Guest House') {
        typeDetails.addAll({
          'rooms': _guestHouseRooms,
          'ac': _guestHouseAc,
          'attached_bathroom': _guestHouseAttachedBathroom,
          'tv': _guestHouseTv,
          'wifi': _guestHouseWifi,
          'room_service': _guestHouseRoomService,
          'parking': _guestHouseParking,
          'power_backup': _guestHousePowerBackup,
          'preference': _guestHousePreference,
          'available_from_date': typeAvailableDate,
        });
      } else if (propertyType == 'Farm House') {
        typeDetails.addAll({
          'land_size': _farmLandSize.toString(),
          'lawn': _farmLawn,
          'garden': _farmGarden,
          'rooms': _farmRooms,
          'hall': _farmHall,
          'swimming_pool': _farmSwimmingPool,
          'parking': _farmParking,
          'electricity': _farmElectricity,
          'water_supply': _farmWaterSupply,
          'suitable_for': _farmSuitableFor,
          'available_from_date': typeAvailableDate,
        });
      }

      final fields = <String, String>{
        'property_type': propertyType,
        'city': _addPageSelectedCityForApi.isNotEmpty ? _addPageSelectedCityForApi : _addPageSelectedCity,
        'address': _selectedLocationAddress ?? '',
        'latitude': _selectedLatitude?.toString() ?? '',
        'longitude': _selectedLongitude?.toString() ?? '',
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'area_size': _areaController.text.trim(),
        'area_unit': _selectedAreaUnit,
        'rent': _rentController.text.trim(),
        'advance_amount': _advanceController.text.trim(),
        'security_deposit': _securityController.text.trim(),
        'is_negotiable': _isNegotiable.toString(),
        'available_from': typeAvailableDate ?? '',
        'available_from_time': _availableFromTimeController.text.trim(),
        'contact_email': _emailController.text.trim(),
        'contact_phone': _phoneController.text.trim(),
        'owner_name': _ownerNameController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'sector': _sectorController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'laundry': _selectedLaundry,
        'mess': _selectedMess,
        'rooms': _selectedRoom.toString(),
        'bathrooms': _selectedBathroom.toString(),
        'kitchen': _selectedKitchen.toString(),
        'tv_lounge': _selectedTVLounge.toString(),
        if (typeDetails.isNotEmpty) 'type_details': jsonEncode(typeDetails),
      };

      final existingToKeep = _isEditMode
          ? [
              for (int i = 0; i < _existingImagePaths.length; i++)
                if (!_removedExistingIndices.contains(i)) _existingImagePaths[i],
            ]
          : <String>[];
      final result = _isEditMode
          ? await ListingApi.updateListing(
              token: token,
              listingId: widget.listingId!,
              fields: fields,
              existingImagePaths: existingToKeep,
              images: _selectedImages,
            )
          : await ListingApi.createListing(
              token: token,
              fields: fields,
              images: _selectedImages,
            );

      if (!mounted) return;

      if (result.success) {
        final isEdit = _isEditMode;
        if (!isEdit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ad saved successfully!',
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
        Navigator.of(context).pop(true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to save. Please try again.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  @override
  void dispose() {
    _areaController.dispose();
    _rentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sectorController.dispose();
    _mapPinController.dispose();
    _landmarkController.dispose();
    _rentPerDayController.dispose();
    _rentPerEventController.dispose();
    _advanceController.dispose();
    _discountController.dispose();
    _maintenanceController.dispose();
    _securityController.dispose();
    _ownerNameController.dispose();
    _whatsappController.dispose();
    _hostelAvailableFromController.dispose();
    _houseAvailableFromController.dispose();
    _shopAvailableFromController.dispose();
    _officeAvailableFromController.dispose();
    _hotelAvailableFromController.dispose();
    _guestHouseAvailableFromController.dispose();
    _farmAvailableFromController.dispose();
    _hostelInTimeRulesController.dispose();
    _shopFrontWidthController.dispose();
    _shopCeilingHeightController.dispose();
    _farmLandSizeController.dispose();
    _availableFromTimeController.dispose();
    super.dispose();
  }

  Widget _gradientIcon(
    IconData icon, {
    Color color1 = AppColors.primary,
    Color color2 = Colors.black,
    double size = 24,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [color1, color2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _isEditMode && !_editLoadComplete
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(size),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInSlide(
                        delay: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              Icons.apartment,
                              'Select Rent Property Type',
                            ),
                            const SizedBox(height: 12),
                            _buildPropertyTypeChips(),
                            _buildDivider(),
                          ],
                        ),
                      ),

                      // Conditional fields based on property type
                      ..._buildPropertySpecificFields(),

                      // Common fields with sliders - Hidden for event properties and for Hostel/Shop
                      if (!_isEventProperty &&
                          _selectedPropertyType != 'Hostel' &&
                          _selectedPropertyType != 'Shop')
                        FadeInSlide(
                          delay: 0.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                Icons.door_sliding_outlined,
                                'Select Room',
                              ),
                              const SizedBox(height: 8),
                              _buildSlider('Rooms', _selectedRoom, 1, 25, (
                                val,
                              ) {
                                setState(() => _selectedRoom = val);
                              }),
                              _buildDivider(),

                              _buildSectionTitle(
                                Icons.bathtub_outlined,
                                'Select Bathrooms',
                              ),
                              const SizedBox(height: 8),
                              _buildSlider(
                                'Bathrooms',
                                _selectedBathroom,
                                1,
                                10,
                                (val) {
                                  setState(() => _selectedBathroom = val);
                                },
                              ),
                              _buildDivider(),

                              _buildSectionTitle(
                                Icons.kitchen_outlined,
                                'Select Kitchen',
                              ),
                              const SizedBox(height: 8),
                              _buildSlider('Kitchens', _selectedKitchen, 1, 5, (
                                val,
                              ) {
                                setState(() => _selectedKitchen = val);
                              }),
                              _buildDivider(),

                              if (_selectedPropertyType != 'Office') ...[
                                _buildSectionTitle(Icons.tv, 'Select TV Lounge'),
                                const SizedBox(height: 8),
                                _buildSlider(
                                  'TV Lounges',
                                  _selectedTVLounge,
                                  1,
                                  5,
                                  (val) {
                                    setState(() => _selectedTVLounge = val);
                                  },
                                ),
                                _buildDivider(),
                              ],
                            ],
                          ),
                        ),

                      FadeInSlide(
                        delay: 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.square_foot, 'Area Size'),
                            const SizedBox(height: 8),
                            _buildAreaSizeField(),
                            _buildDivider(),

                            _buildSectionTitle(
                              Icons.location_city,
                              'Select City',
                            ),
                            const SizedBox(height: 8),
                            _buildCitySelector(),
                            _buildDivider(),

                            _buildSectionTitle(
                              Icons.location_on,
                              'Select Location',
                            ),
                            const SizedBox(height: 8),
                            _buildLocationSelector(),
                            _buildDivider(),
                          ],
                        ),
                      ),

                      if (!_isEventProperty)
                        FadeInSlide(
                          delay: 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedPropertyType != 'House' &&
                                  _selectedPropertyType != 'Flat' &&
                                  _selectedPropertyType != 'Office' &&
                                  _selectedPropertyType != 'Shop' &&
                                  _selectedPropertyType != 'Hotel') ...[
                                _buildSectionTitle(
                                  Icons.local_laundry_service,
                                  'Select Laundry',
                                ),
                                const SizedBox(height: 8),
                                _buildDropdown(
                                  'Laundry',
                                  _selectedLaundry,
                                  ['Yes', 'No'],
                                  (val) {
                                    setState(() => _selectedLaundry = val!);
                                  },
                                ),
                                _buildDivider(),

                                _buildSectionTitle(
                                  Icons.restaurant,
                                  'Select Mess',
                                ),
                                const SizedBox(height: 8),
                                _buildDropdown(
                                  'Mess',
                                  _selectedMess,
                                  ['Yes', 'No'],
                                  (val) {
                                    setState(() => _selectedMess = val!);
                                  },
                                ),
                                _buildDivider(),
                              ],
                            ],
                          ),
                        ),

                      FadeInSlide(
                        delay: 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEventProperty) ...[
                              _buildModernRentSection(),
                            ],

                            _buildSectionTitle(Icons.title, 'Property Title'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _titleController,
                              'Enter title',
                              'Property Title required',
                            ),
                            _buildDivider(),

                            _buildSectionTitle(
                              Icons.description,
                              'Property Description',
                            ),
                            const SizedBox(height: 8),
                            _buildDescriptionField(),
                            _buildDivider(),
                          ],
                        ),
                      ),

                      FadeInSlide(
                        delay: 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.email, 'Email Address'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _emailController,
                              'Enter email',
                              'Email required',
                              TextInputType.emailAddress,
                            ),
                            _buildDivider(),

                            // Unified Contact Section for all property types
                            _buildSectionTitle(Icons.person, 'Owner Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _ownerNameController,
                              'Enter name',
                              'Name required',
                            ),
                            _buildDivider(),
                            _buildSectionTitle(Icons.chat, 'WhatsApp Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _whatsappController,
                              'Enter WhatsApp number',
                              'WhatsApp required',
                              TextInputType.phone,
                              [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                            _buildDivider(),
                            _buildSectionTitle(Icons.phone, 'Contact Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _phoneController,
                              'Enter phone number',
                              'Phone required',
                              TextInputType.phone,
                              [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                            _buildDivider(),
                          ],
                        ),
                      ),

                      FadeInSlide(
                        delay: 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.image, 'Upload Images'),
                            const SizedBox(height: 8),
                            _buildImageUploadSection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),

                      FadeInSlide(
                        delay: 0.75,
                        child: _buildSelectedImagesRow(),
                      ),

                      FadeInSlide(
                        delay: 0.8,
                        child: Column(
                          children: [
                            _buildSaveButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            colorScheme.outline.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.24,
      child: Stack(
        children: [
          // Background with curved shape - RED color
          Positioned.fill(child: CustomPaint(painter: _HeaderCurvePainter())),
          // Content
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Row(
              children: [
                // Bigger image with curved container behind
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                  child: Image.asset(
                    AppImages.addHome,
                    height: size.height * 0.2, // Made it bigger
                    color: Colors.white, // Made it white as requested
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Title with shadow
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Post an Ad',
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share your property',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _gradientIcon(
              icon,
              color1: AppColors.primary,
              color2: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeChips() {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _propertyTypes.map((type) {
        final isSelected = _selectedPropertyType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPropertyType = type;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : colorScheme.outline.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildPropertySpecificFields() {
    switch (_selectedPropertyType) {
      case 'Hostel':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.wc, 'Hostel Type'),
                const SizedBox(height: 8),
                _buildHostelTypeChips(),
                _buildDivider(),

                _buildSectionTitle(Icons.meeting_room, 'Room Type'),
                const SizedBox(height: 8),
                _buildDropdown('Type', _hostelRoomType, _hostelRoomTypes, (
                  val,
                ) {
                  setState(() => _hostelRoomType = val!);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.bed, 'Beds per Room'),
                const SizedBox(height: 12),
                _buildBedsGrid(),
                _buildDivider(),

                _buildSectionTitle(Icons.room_preferences, 'Room Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Attached Washroom': _hostelAttachedWashroom,
                    'AC': _hostelAc,
                    'Study Table & Chair': _hostelStudyTable,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Attached Washroom')
                        _hostelAttachedWashroom = val;
                      if (key == 'AC') _hostelAc = val;
                      if (key == 'Study Table & Chair') _hostelStudyTable = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(
                  Icons.featured_play_list,
                  'Facilities / Amenities',
                ),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Food Included': _hostelFoodIncluded,
                    'WiFi': _hostelWifi,
                    'Laundry': _hostelLaundry,
                    '24 Hours Water': _hostelWater24,
                    'Power Backup': _hostelPowerBackup,
                    'Security / CCTV': _hostelSecurity,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Food Included') _hostelFoodIncluded = val;
                      if (key == 'WiFi') _hostelWifi = val;
                      if (key == 'Laundry') _hostelLaundry = val;
                      if (key == '24 Hours Water') _hostelWater24 = val;
                      if (key == 'Power Backup') _hostelPowerBackup = val;
                      if (key == 'Security / CCTV') _hostelSecurity = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.people, 'Preferences'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Suitable For',
                  _hostelPreference,
                  _hostelPreferences,
                  (val) {
                    setState(() => _hostelPreference = val!);
                  },
                ),
                const SizedBox(height: 12),
                _buildCheckboxes(
                  {
                    'Smoking Allowed': _hostelSmokingAllowed,
                    'Alcohol Allowed': _hostelAlcoholAllowed,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Smoking Allowed') _hostelSmokingAllowed = val;
                      if (key == 'Alcohol Allowed') _hostelAlcoholAllowed = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.access_time, 'In Time Rules'),
                const SizedBox(height: 8),
                _buildTextField(
                  _hostelInTimeRulesController,
                  'e.g., 10 PM or No restriction',
                  '',
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _hostelAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'House':
      case 'Flat':
        final isHouse = _selectedPropertyType == 'House';
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isHouse) ...[
                  _buildSectionTitle(Icons.home, 'House Details'),
                  const SizedBox(height: 8),
                  _buildDropdown('House Type', _selectedPortion, _portions, (
                    val,
                  ) {
                    setState(() => _selectedPortion = val!);
                  }),
                  _buildDivider(),
                ],

                _buildSectionTitle(Icons.chair, 'Furnished Status'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Status',
                  isHouse ? _houseFurnished : _flatFurnished,
                  _furnishedOptions,
                  (val) {
                    setState(() {
                      if (isHouse) {
                        _houseFurnished = val!;
                      } else {
                        _flatFurnished = val!;
                      }
                    });
                  },
                ),
                _buildDivider(),

                if (isHouse) ...[
                  _buildSectionTitle(Icons.featured_play_list, 'Features'),
                  const SizedBox(height: 8),
                  _buildCheckboxes(
                    {
                      'Balcony': _houseBalcony,
                      'Modular Kitchen': _houseModularKitchen,
                      'Lift': _houseLift,
                      'Parking': _houseParking,
                    },
                    (key, val) {
                      setState(() {
                        if (key == 'Balcony') _houseBalcony = val;
                        if (key == 'Modular Kitchen')
                          _houseModularKitchen = val;
                        if (key == 'Lift') _houseLift = val;
                        if (key == 'Parking') _houseParking = val;
                      });
                    },
                  ),
                  _buildDivider(),
                ],

                _buildSectionTitle(Icons.apartment_outlined, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  isHouse
                      ? {
                          '24 Hours Water': _houseWater24,
                          'Power Backup': _housePowerBackup,
                          'Security / CCTV': _houseSecurity,
                          'Gated Society': _houseGatedSociety,
                        }
                      : {
                          '24 Hours Water': _flatWater24,
                          'Security / CCTV': _flatSecurity,
                          'Gated Society': _flatGatedSociety,
                        },
                  (key, val) {
                    setState(() {
                      if (isHouse) {
                        if (key == '24 Hours Water') _houseWater24 = val;
                        if (key == 'Power Backup') _housePowerBackup = val;
                        if (key == 'Security / CCTV') _houseSecurity = val;
                        if (key == 'Gated Society') _houseGatedSociety = val;
                      } else {
                        if (key == '24 Hours Water') _flatWater24 = val;
                        if (key == 'Security / CCTV') _flatSecurity = val;
                        if (key == 'Gated Society') _flatGatedSociety = val;
                      }
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.people, 'Preferences'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Suitable For',
                  _housePreference,
                  _housePreferences,
                  (val) {
                    setState(() => _housePreference = val!);
                  },
                ),
                const SizedBox(height: 12),
                _buildCheckboxes(
                  {
                    'Pets Allowed': _housePetsAllowed,
                    'Non-Veg Allowed': _houseVegNonVeg,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Pets Allowed') _housePetsAllowed = val;
                      if (key == 'Non-Veg Allowed') _houseVegNonVeg = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _houseAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Shop':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.store, 'Shop Details'),
                const SizedBox(height: 8),
                _buildDropdown('Location Type', _shopLocation, _shopLocations, (
                  val,
                ) {
                  setState(() => _shopLocation = val!);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.straighten, 'Shop Dimensions'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        TextEditingController(text: _shopFrontWidth.toString())
                          ..addListener(() {
                            _shopFrontWidth =
                                double.tryParse(
                                  TextEditingController(
                                    text: _shopFrontWidth.toString(),
                                  ).text,
                                ) ??
                                0;
                          }),
                        'Front Width (ft)',
                        '',
                        TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        TextEditingController(
                          text: _shopCeilingHeight.toString(),
                        )..addListener(() {
                          _shopCeilingHeight =
                              double.tryParse(
                                TextEditingController(
                                  text: _shopCeilingHeight.toString(),
                                ).text,
                              ) ??
                              0;
                        }),
                        'Ceiling Height (ft)',
                        '',
                        TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.door_front_door, 'Front Type'),
                const SizedBox(height: 8),
                _buildDropdown('Type', _shopFrontType, _shopFrontTypes, (val) {
                  setState(() => _shopFrontType = val!);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.featured_play_list, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Electricity': _shopElectricity,
                    'Water': _shopWater,
                    'Washroom': _shopWashroom,
                    'Parking Nearby': _shopParking,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Electricity') _shopElectricity = val;
                      if (key == 'Water') _shopWater = val;
                      if (key == 'Washroom') _shopWashroom = val;
                      if (key == 'Parking Nearby') _shopParking = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.business, 'Suitable For'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Business Type',
                  _shopSuitableFor,
                  _shopSuitableOptions,
                  (val) {
                    setState(() => _shopSuitableFor = val!);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _shopAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Office':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.chair, 'Furnished Status'),
                const SizedBox(height: 8),
                _buildDropdown('Status', _officeFurnished, _furnishedOptions, (
                  val,
                ) {
                  setState(() => _officeFurnished = val!);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.layers, 'Floor Number'),
                const SizedBox(height: 8),
                _buildSlider('Floor', _selectedOfficeFloor, 0, 50, (val) {
                  setState(() => _selectedOfficeFloor = val);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.meeting_room, 'Office Layout'),
                const SizedBox(height: 8),
                _buildSlider('Cabins', _officeCabins, 0, 20, (val) {
                  setState(() => _officeCabins = val);
                }),
                const SizedBox(height: 12),
                _buildSlider('Workstations', _officeWorkstations, 0, 100, (
                  val,
                ) {
                  setState(() => _officeWorkstations = val);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.featured_play_list, 'Office Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Conference Room': _officeConferenceRoom,
                    'Reception Area': _officeReception,
                    'Lift': _officeLift,
                    'Parking': _officeParking,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Conference Room') _officeConferenceRoom = val;
                      if (key == 'Reception Area') _officeReception = val;
                      if (key == 'Lift') _officeLift = val;
                      if (key == 'Parking') _officeParking = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.power, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Power Backup': _officePowerBackup,
                    'Internet Ready': _officeInternetReady,
                    'Security': _officeSecurity,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Power Backup') _officePowerBackup = val;
                      if (key == 'Internet Ready') _officeInternetReady = val;
                      if (key == 'Security') _officeSecurity = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.business, 'Suitable For'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Business Type',
                  _officeSuitableFor,
                  _officeSuitableOptions,
                  (val) {
                    setState(() => _officeSuitableFor = val!);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _officeAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Hotel':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.hotel, 'Rooms (Kamray)'),
                const SizedBox(height: 8),
                _buildSlider('Number of Rooms', _hotelRooms, 1, 100, (val) {
                  setState(() => _hotelRooms = val);
                }),
                _buildDivider(),
                _buildDropdown('AC / Non-AC', _hotelAcType, _hotelAcOptions, (val) {
                  setState(() => _hotelAcType = val!);
                }),
                _buildDivider(),
                _buildCheckboxes(
                  {
                    'Clean Beds': _hotelCleanBeds,
                    'Attached Bathroom': _hotelAttachedBathroom,
                    'Family Rooms': _hotelFamilyRooms,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Clean Beds') _hotelCleanBeds = val;
                      if (key == 'Attached Bathroom') _hotelAttachedBathroom = val;
                      if (key == 'Family Rooms') _hotelFamilyRooms = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.wifi, 'Free Wi-Fi'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {'Free Wi-Fi': _hotelWifi},
                  (key, val) => setState(() => _hotelWifi = val),
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.local_parking, 'Parking'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {'Free Parking': _hotelParking},
                  (key, val) => setState(() => _hotelParking = val),
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.restaurant, 'Restaurant / Food'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Breakfast': _hotelBreakfast,
                    'Lunch / Dinner': _hotelLunchDinner,
                    'Room Service': _hotelRoomService,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Breakfast') _hotelBreakfast = val;
                      if (key == 'Lunch / Dinner') _hotelLunchDinner = val;
                      if (key == 'Room Service') _hotelRoomService = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.security, 'Security'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'CCTV Cameras': _hotelCctv,
                    '24-Hour Security': _hotelSecurity24,
                    'Safe Environment': _hotelSafeEnv,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'CCTV Cameras') _hotelCctv = val;
                      if (key == '24-Hour Security') _hotelSecurity24 = val;
                      if (key == 'Safe Environment') _hotelSafeEnv = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.place, 'Location'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Near Market': _hotelNearMarket,
                    'Near Bus Stand / Station': _hotelNearBusStand,
                    'Near Tourist Place': _hotelNearTourist,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Near Market') _hotelNearMarket = val;
                      if (key == 'Near Bus Stand / Station') _hotelNearBusStand = val;
                      if (key == 'Near Tourist Place') _hotelNearTourist = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.spa, 'Extra Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Laundry Service': _hotelLaundry,
                    'Swimming Pool': _hotelSwimmingPool,
                    'Gym': _hotelGym,
                    'Conference Hall': _hotelConferenceHall,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Laundry Service') _hotelLaundry = val;
                      if (key == 'Swimming Pool') _hotelSwimmingPool = val;
                      if (key == 'Gym') _hotelGym = val;
                      if (key == 'Conference Hall') _hotelConferenceHall = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _hotelAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Marquee':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed Marquee Details heading as requested

                _buildSectionTitle(Icons.groups, 'Capacity'),
                const SizedBox(height: 8),
                _buildSlider('Guest Capacity', _maxGuests, 50, 5000, (val) {
                  setState(() => _maxGuests = val);
                }),
                const SizedBox(height: 12),
                _buildSlider(
                  'Parking Capacity',
                  _marqueeParkingCapacity,
                  0,
                  500,
                  (val) {
                    setState(() => _marqueeParkingCapacity = val);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.featured_play_list, 'Hall Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'AC': _marqueeAc,
                    'Stage': _marqueeStage,
                    'Bridal Room': _marqueeBridalRoom,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'AC') _marqueeAc = val;
                      if (key == 'Stage') _marqueeStage = val;
                      if (key == 'Bridal Room') _marqueeBridalRoom = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.restaurant, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Generator Backup': _marqueeGenerator,
                    'Decoration Available': _marqueeDecoration,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Generator Backup') _marqueeGenerator = val;
                      if (key == 'Decoration Available')
                        _marqueeDecoration = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  'Catering',
                  _marqueeCatering,
                  _marqueeCateringOptions,
                  (val) {
                    setState(() => _marqueeCatering = val!);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.celebration, 'Suitable For'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Event Type',
                  _marqueeSuitableFor,
                  _marqueeSuitableOptions,
                  (val) {
                    setState(() => _marqueeSuitableFor = val!);
                  },
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Guest House':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.hotel, 'Guest House Details'),
                const SizedBox(height: 8),

                _buildSlider('Number of Rooms', _guestHouseRooms, 1, 50, (val) {
                  setState(() => _guestHouseRooms = val);
                }),
                _buildDivider(),

                _buildSectionTitle(Icons.room_preferences, 'Room Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'AC': _guestHouseAc,
                    'Attached Bathroom': _guestHouseAttachedBathroom,
                    'TV': _guestHouseTv,
                    'WiFi': _guestHouseWifi,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'AC') _guestHouseAc = val;
                      if (key == 'Attached Bathroom')
                        _guestHouseAttachedBathroom = val;
                      if (key == 'TV') _guestHouseTv = val;
                      if (key == 'WiFi') _guestHouseWifi = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.featured_play_list, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Room Service': _guestHouseRoomService,
                    'Parking': _guestHouseParking,
                    'Power Backup': _guestHousePowerBackup,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Room Service') _guestHouseRoomService = val;
                      if (key == 'Parking') _guestHouseParking = val;
                      if (key == 'Power Backup') _guestHousePowerBackup = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.people, 'Preferences'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Suitable For',
                  _guestHousePreference,
                  _guestHousePreferences,
                  (val) {
                    setState(() => _guestHousePreference = val!);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _guestHouseAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      case 'Farm House':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.landscape, 'Farm House Details'),
                const SizedBox(height: 8),

                _buildTextField(
                  TextEditingController(text: _farmLandSize.toString())
                    ..addListener(() {
                      _farmLandSize =
                          double.tryParse(
                            TextEditingController(
                              text: _farmLandSize.toString(),
                            ).text,
                          ) ??
                          0;
                    }),
                  'Land Size (acres/kanals)',
                  '',
                  TextInputType.number,
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.grass, 'Property Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Lawn / Garden': _farmLawn || _farmGarden,
                    'Rooms / Hall': _farmRooms || _farmHall,
                    'Swimming Pool': _farmSwimmingPool,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Lawn / Garden') {
                        _farmLawn = val;
                        _farmGarden = val;
                      }
                      if (key == 'Rooms / Hall') {
                        _farmRooms = val;
                        _farmHall = val;
                      }
                      if (key == 'Swimming Pool') _farmSwimmingPool = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.featured_play_list, 'Facilities'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  {
                    'Parking': _farmParking,
                    'Electricity': _farmElectricity,
                    'Water Supply': _farmWaterSupply,
                  },
                  (key, val) {
                    setState(() {
                      if (key == 'Parking') _farmParking = val;
                      if (key == 'Electricity') _farmElectricity = val;
                      if (key == 'Water Supply') _farmWaterSupply = val;
                    });
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.celebration, 'Suitable For'),
                const SizedBox(height: 8),
                _buildDropdown(
                  'Purpose',
                  _farmSuitableFor,
                  _farmSuitableOptions,
                  (val) {
                    setState(() => _farmSuitableFor = val!);
                  },
                ),
                _buildDivider(),

                _buildSectionTitle(Icons.calendar_today, 'Available From'),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  _farmAvailableFromController,
                  'Select date',
                ),
                const SizedBox(height: 12),
                _buildTimePickerField(
                  _availableFromTimeController,
                  'Select time (optional)',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildHostelTypeChips() {
    return Row(
      children: ['Boys', 'Girls'].map((type) {
        final isSelected = _selectedHostelType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedHostelType = type;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBedsGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(10, (index) {
        final bedNum = index + 1;
        final isSelected = _selectedBeds == bedNum;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBeds = bedNum;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$bedNum',
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Compact Slider widget for number selection
  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primary.withValues(
                      alpha: 0.2,
                    ),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: value.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min <= 0 ? 1 : max - min,
                    onChanged: (val) => onChanged(val.toInt()),
                  ),
                ),
              ),
              Text(
                '$min-$max',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: _gradientIcon(
                Icons.keyboard_arrow_down,
                color1: AppColors.primary,
                color2: Colors.black,
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxes(
    Map<String, bool> items,
    Function(String, bool) onChanged,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.keys.map((key) {
        final isSelected = items[key]!;
        return GestureDetector(
          onTap: () => onChanged(key, !isSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  key,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernRentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.payments, 'Rent & Financials'),
        const SizedBox(height: 12),
        _buildTextField(
          _rentController,
          _selectedPropertyType == 'Hostel'
              ? 'Monthly rent (per bed)'
              : _selectedPropertyType == 'Hotel'
                  ? 'Rent (per night) PKR'
                  : 'Monthly rent',
          'Required',
          TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _advanceController,
                _selectedPropertyType == 'Hotel'
                    ? 'Advance amount (optional)'
                    : 'Advance amount',
                _selectedPropertyType == 'Hotel' ? '' : 'Required',
                TextInputType.number,
              ),
            ),
            if (_selectedPropertyType == 'Flat' ||
                _selectedPropertyType == 'Office') ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _maintenanceController,
                  'Maintenance charges',
                  'Required',
                  TextInputType.number,
                ),
              ),
            ],
            if (_selectedPropertyType == 'Hostel' ||
                _selectedPropertyType == 'House') ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _securityController,
                  'Security / Advance',
                  'Required',
                  TextInputType.number,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Negotiable',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
            const Spacer(),
            Switch(
              value: _isNegotiable,
              activeTrackColor: AppColors.primary,
              onChanged: (val) => setState(() => _isNegotiable = val),
            ),
            Text(
              _isNegotiable ? '✔️' : '❌',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildAreaSizeField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAreaUnit,
                icon: _gradientIcon(
                  Icons.keyboard_arrow_down,
                  color1: AppColors.primary,
                  color2: Colors.black,
                  size: 20,
                ),
                items: _areaUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedAreaUnit = val!);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SearchCityView(
              selectedCityName: _addPageSelectedCity,
              onCitySelected: (name, imagePath, cityForApi) {
                setState(() {
                  _addPageSelectedCity = name;
                  _addPageSelectedCityForApi = cityForApi;
                });
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _addPageSelectedCity.isEmpty ? 'Select City' : _addPageSelectedCity,
              style: TextStyle(
                fontSize: 16,
                color: _addPageSelectedCity.isEmpty
                    ? colorScheme.onSurface.withValues(alpha: 0.6)
                    : colorScheme.onSurface,
              ),
            ),
            _gradientIcon(
              Icons.chevron_right,
              color1: AppColors.primary,
              color2: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMapsAndSetAddress() async {
    final result = await MapLocationPicker.open(
      context,
      initialAddress: _selectedLocationAddress,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedLocationAddress = result['address'] as String?;
        _selectedLatitude = result['latitude'] as double?;
        _selectedLongitude = result['longitude'] as double?;
      });
    }
  }

  Widget _buildLocationSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _openMapsAndSetAddress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLocationAddress ?? 'Select Location',
                    style: TextStyle(
                      color: _selectedLocationAddress != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedLatitude != null && _selectedLongitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${_selectedLatitude!.toStringAsFixed(5)}, ${_selectedLongitude!.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            _gradientIcon(
              Icons.chevron_right,
              color1: AppColors.primary,
              color2: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element - rent field builder (kept for future Rent section)
  Widget _buildRentField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _rentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: InputBorder.none,
                errorStyle: const TextStyle(color: AppColors.primary),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rent Price required';
                }
                return null;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PKR',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    String errorText, [
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.primary),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return errorText.isEmpty ? null : errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Enter description',
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.primary),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Property Description required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField(
    TextEditingController controller,
    String hint, {
    String? errorText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        onTap: () => _pickDate(controller),
        validator: (value) {
          if (errorText != null &&
              errorText.isNotEmpty &&
              (value == null || value.isEmpty)) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimePickerField(
    TextEditingController controller,
    String hint, {
    String? errorText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.access_time, size: 20),
        ),
        onTap: () => _pickTime(controller),
        validator: (value) {
          if (errorText != null &&
              errorText.isNotEmpty &&
              (value == null || value.isEmpty)) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGuideline(
          Icons.check_circle,
          'Upload good quality pictures with proper lighting.',
        ),
        const SizedBox(height: 8),
        _buildImageGuideline(
          Icons.check_circle,
          'Upload images min 1 & max 6.',
        ),
        const SizedBox(height: 8),
        _buildImageGuideline(
          Icons.check_circle,
          'Cover all areas of your property.',
        ),
        const SizedBox(height: 20),
        // Dotted border container with centered buttons
        CustomPaint(
          painter: _DottedBorderPainter(
            color: AppColors.primary.withValues(alpha: 0.6),
            strokeWidth: 2,
            gap: 6,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadButton(Icons.image, 'Gallery', _pickFromGallery),
                const SizedBox(height: 16),
                _buildUploadButton(Icons.camera_alt, 'Camera', _pickFromCamera),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGuideline(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientIcon(
          icon,
          color1: Colors.green,
          color2: Colors.green.shade700,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
              AppColors.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
            ),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _gradientIcon(
                icon,
                color1: AppColors.primary,
                color2: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagesRow() {
    final existingCount = _existingImagePaths.length - _removedExistingIndices.length;
    final totalCount = existingCount + _selectedImages.length;
    if (totalCount == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          Icons.collections,
          _isEditMode ? 'Images (${totalCount}/$_maxImages)' : 'Selected Images',
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing images from API (edit mode)
              ...List.generate(_existingImagePaths.length, (index) {
                if (_removedExistingIndices.contains(index)) return const SizedBox.shrink();
                final path = _existingImagePaths[index];
                final url = path.startsWith('http') ? path : uploadsUrl('/$path');
                return Padding(
                  padding: EdgeInsets.only(right: index < _existingImagePaths.length - 1 ? 12 : 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeExistingImageAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_existingImagePaths.isNotEmpty && _selectedImages.isNotEmpty) const SizedBox(width: 12),
              // Newly picked images
              ...List.generate(_selectedImages.length, (index) {
                final path = _selectedImages[index];
                return Padding(
                  padding: EdgeInsets.only(right: index < _selectedImages.length - 1 ? 12 : 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (path.startsWith('assets/')
                            ? Image.asset(path, width: 72, height: 72, fit: BoxFit.cover)
                            : Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover)),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeImageAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
      ],
    );
  }

  // Save button - same style as other buttons in project (solid red)
  Widget _buildSaveButton() {
    return AppPrimaryButton(
      label: _isEditMode ? 'Save Changes' : 'Save',
      onPressed: _isSaving ? null : _handleSave,
      isLoading: _isSaving,
      loader: const LogoLoader(size: 22),
    );
  }
}

// Custom painter for header curve - RED color
class _HeaderCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.1,
      0,
      size.height * 0.8,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Draw subtle circle decoration
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.4),
      size.width * 0.25,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for dotted border
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final length = draw ? gap * 2 : gap;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
