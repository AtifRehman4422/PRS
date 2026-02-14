import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  final _formKey = GlobalKey<FormState>();

  // Property Type
  String _selectedPropertyType = 'Hostel';
  final List<String> _propertyTypes = [
    'Hostel',
    'House',
    'Flat',
    'Office',
    'Shop',
    'Marquee',
    'Guest House',
    'Farm House',
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

  final String _selectedCity = 'Islamabad';
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
  final _hostelInTimeRulesController = TextEditingController();
  final _shopFrontWidthController = TextEditingController();
  final _shopCeilingHeightController = TextEditingController();
  final _farmLandSizeController = TextEditingController();

  final List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 6; // Min 1 & max 6 per guideline

  void _addImage(String path) {
    if (_selectedImages.length >= _maxImages) return;
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
      final remaining = _maxImages - _selectedImages.length;
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
            if (_selectedImages.length < _maxImages) _selectedImages.add(path);
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
      if (_selectedImages.length >= _maxImages) {
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
    _guestHouseAvailableFromController.dispose();
    _farmAvailableFromController.dispose();
    _hostelInTimeRulesController.dispose();
    _shopFrontWidthController.dispose();
    _shopCeilingHeightController.dispose();
    _farmLandSizeController.dispose();
    super.dispose();
  }

  Widget _gradientIcon(
    IconData icon, {
    Color color1 = Colors.red,
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
        child: Form(
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
                                  _selectedPropertyType != 'Flat') ...[
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
                            ),
                            _buildDivider(),
                            _buildSectionTitle(Icons.phone, 'Contact Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              _phoneController,
                              'Enter phone number',
                              'Phone required',
                              TextInputType.phone,
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
                _buildTextField(
                  _hostelAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                _buildSectionTitle(
                  isHouse ? Icons.home : Icons.apartment,
                  isHouse ? 'House Details' : 'Flat Details',
                ),
                const SizedBox(height: 8),

                if (isHouse) ...[
                  _buildDropdown('House Type', _selectedPortion, _portions, (
                    val,
                  ) {
                    setState(() => _selectedPortion = val!);
                  }),
                  _buildDivider(),
                ],

                if (!isHouse) ...[
                  _buildDropdown('BHK Type', _selectedBHK, _bhkTypes, (val) {
                    setState(() => _selectedBHK = val!);
                  }),
                  _buildDivider(),
                ],

                if (!isHouse) ...[
                  _buildSectionTitle(Icons.layers, 'Floor Number'),
                  const SizedBox(height: 8),
                  _buildSlider('Floor', _selectedFloor, 1, 30, (val) {
                    setState(() => _selectedFloor = val);
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

                _buildSectionTitle(Icons.featured_play_list, 'Features'),
                const SizedBox(height: 8),
                _buildCheckboxes(
                  isHouse
                      ? {
                          'Balcony': _houseBalcony,
                          'Modular Kitchen': _houseModularKitchen,
                          'Lift': _houseLift,
                          'Parking': _houseParking,
                        }
                      : {
                          'Lift': _flatLift,
                          'Balcony': _flatBalcony,
                          'Modular Kitchen': _flatModularKitchen,
                          'Parking': _flatParking,
                          'Backup Generator': _flatGenerator,
                        },
                  (key, val) {
                    setState(() {
                      if (isHouse) {
                        if (key == 'Balcony') _houseBalcony = val;
                        if (key == 'Modular Kitchen')
                          _houseModularKitchen = val;
                        if (key == 'Lift') _houseLift = val;
                        if (key == 'Parking') _houseParking = val;
                      } else {
                        if (key == 'Lift') _flatLift = val;
                        if (key == 'Balcony') _flatBalcony = val;
                        if (key == 'Modular Kitchen') _flatModularKitchen = val;
                        if (key == 'Parking') _flatParking = val;
                        if (key == 'Backup Generator') _flatGenerator = val;
                      }
                    });
                  },
                ),
                _buildDivider(),

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
                _buildTextField(
                  _houseAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                _buildTextField(
                  _shopAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                _buildSectionTitle(Icons.business_center, 'Office Details'),
                const SizedBox(height: 8),

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
                _buildTextField(
                  _officeAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                _buildTextField(
                  _guestHouseAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                _buildTextField(
                  _farmAvailableFromController,
                  'Select date',
                  '',
                  TextInputType.datetime,
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
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
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
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
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
                'Advance amount',
                'Required',
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
        // TODO: Open city selection
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
            Text(_selectedCity, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
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

  Widget _buildLocationSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        // TODO: Open location selection
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
              'Select Location',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.primary),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
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
                color2: Colors.red.shade700,
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
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.collections, 'Selected Images'),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final path = _selectedImages[index];
              return Stack(
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
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
      ],
    );
  }

  // Save button - same style as other buttons in project (solid red)
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          if (_selectedImages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please add at least 1 image (Camera or Gallery)'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          // TODO: upload _selectedImages and form data to backend
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad posted successfully!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
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
