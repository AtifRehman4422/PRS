import 'package:flutter/material.dart';
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
  ];

  // Hostel specific
  String _selectedHostelType = 'Boys';
  int _selectedBeds = 1;

  // House specific
  String _selectedPortion = 'Upper Portion';
  final List<String> _portions = [
    'Upper Portion',
    'Lower Portion',
    'Middle Portion',
    'Full',
  ];

  // Flat specific
  int _selectedFloor = 1;

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

  String _selectedCity = 'Islamabad';

  // Controllers
  final _areaController = TextEditingController();
  final _rentController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _areaController.dispose();
    _rentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      backgroundColor: AppColors.surface,
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

                      // Common fields with sliders
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
                            _buildSlider(_selectedRoom, 1, 25, (val) {
                              setState(() => _selectedRoom = val);
                            }),
                            _buildDivider(),

                            _buildSectionTitle(
                              Icons.bathtub_outlined,
                              'Select Bathrooms',
                            ),
                            const SizedBox(height: 8),
                            _buildSlider(_selectedBathroom, 1, 10, (val) {
                              setState(() => _selectedBathroom = val);
                            }),
                            _buildDivider(),

                            _buildSectionTitle(
                              Icons.kitchen_outlined,
                              'Select Kitchen',
                            ),
                            const SizedBox(height: 8),
                            _buildSlider(_selectedKitchen, 1, 5, (val) {
                              setState(() => _selectedKitchen = val);
                            }),
                            _buildDivider(),

                            _buildSectionTitle(Icons.tv, 'Select TV Lounge'),
                            const SizedBox(height: 8),
                            _buildSlider(_selectedTVLounge, 1, 5, (val) {
                              setState(() => _selectedTVLounge = val);
                            }),
                            _buildDivider(),
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

                      FadeInSlide(
                        delay: 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              Icons.local_laundry_service,
                              'Select Laundry',
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(_selectedLaundry, ['Yes', 'No'], (
                              val,
                            ) {
                              setState(() => _selectedLaundry = val!);
                            }),
                            _buildDivider(),

                            _buildSectionTitle(Icons.restaurant, 'Select Mess'),
                            const SizedBox(height: 8),
                            _buildDropdown(_selectedMess, ['Yes', 'No'], (val) {
                              setState(() => _selectedMess = val!);
                            }),
                            _buildDivider(),
                          ],
                        ),
                      ),

                      FadeInSlide(
                        delay: 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.sell, 'Property Rent'),
                            const SizedBox(height: 8),
                            _buildRentField(),
                            _buildDivider(),

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

                            _buildSectionTitle(Icons.phone, 'Contact Number'),
                            const SizedBox(height: 8),
                            _buildPhoneField(),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.borderLight,
            AppColors.primary.withOpacity(0.3),
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
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                  child: Image.asset(
                    AppImages.addHome,
                    height: size.height * 0.16,
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
                            color: Colors.black.withOpacity(0.2),
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
                        color: Colors.white.withOpacity(0.9),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeChips() {
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
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
                _buildSectionTitle(Icons.home_work, 'Select Hostel'),
                const SizedBox(height: 8),
                _buildHostelTypeChips(),
                _buildDivider(),
                _buildSectionTitle(Icons.bed, 'Select Beds'),
                const SizedBox(height: 12),
                _buildBedsGrid(),
                _buildDivider(),
              ],
            ),
          ),
        ];
      case 'House':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.home, 'Portions'),
                const SizedBox(height: 8),
                _buildDropdown(_selectedPortion, _portions, (val) {
                  setState(() => _selectedPortion = val!);
                }),
                _buildDivider(),
              ],
            ),
          ),
        ];
      case 'Flat':
        return [
          FadeInSlide(
            delay: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.home, 'Floors'),
                const SizedBox(height: 8),
                _buildSlider(_selectedFloor, 1, 20, (val) {
                  setState(() => _selectedFloor = val);
                }),
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
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
              color: isSelected ? null : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
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
                  color: isSelected ? Colors.white : AppColors.textPrimary,
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
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Current value display
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
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.1),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
          // Range labels
          Text(
            '$min-$max',
            style: TextStyle(color: AppColors.hintText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
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
    );
  }

  Widget _buildAreaSizeField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter',
                hintStyle: TextStyle(color: AppColors.hintText),
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
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
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
                    child: Text(unit, style: const TextStyle(fontSize: 14)),
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
    return InkWell(
      onTap: () {
        // TODO: Open city selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedCity, style: const TextStyle(fontSize: 16)),
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
    return InkWell(
      onTap: () {
        // TODO: Open location selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Location',
              style: TextStyle(color: AppColors.hintText, fontSize: 16),
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

  Widget _buildRentField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _rentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.hintText),
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
              color: AppColors.primary.withOpacity(0.1),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.hintText),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Enter description',
          hintStyle: TextStyle(color: AppColors.hintText),
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

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _gradientIcon(
                  Icons.arrow_drop_down,
                  color1: AppColors.primary,
                  color2: Colors.black,
                ),
                const Text('🇵🇰', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                const Text(
                  '+92',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.borderLight),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: AppColors.hintText),
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Text(
            '${_phoneController.text.length}/10',
            style: TextStyle(color: AppColors.hintText, fontSize: 12),
          ),
        ],
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
            color: AppColors.primary.withOpacity(0.6),
            strokeWidth: 2,
            gap: 6,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadButton(Icons.image, 'From Gallery', () {
                  // TODO: Pick from gallery
                }),
                const SizedBox(height: 16),
                _buildUploadButton(Icons.camera_alt, 'From Camera', () {
                  // TODO: Pick from camera
                }),
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
            ),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
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

  // Save button - same style as other buttons in project (solid red)
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Handle save
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ad posted successfully!'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
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
      ..color = Colors.white.withOpacity(0.15)
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
