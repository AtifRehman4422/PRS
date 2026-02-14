import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final _nameController = TextEditingController(text: 'M Atif Rehman');
  final _emailController = TextEditingController(text: 'atifrehman442@gmail.com');
  final _phoneController = TextEditingController(text: '+92 300 1234567');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Logo
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  AppImages.logo,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // Profile Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                FadeInSlide(
                  delay: 0.1,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(AppImages.one), // Placeholder user image
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                FadeInSlide(
                  delay: 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          value: '........',
                          isObscure: true,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            child: Text(
                              _isEditing ? 'Save Changes' : 'Edit Profile',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? value,
    bool isObscure = false,
    bool isReadOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            readOnly: isReadOnly || !_isEditing,
            decoration: InputDecoration(
              hintText: value,
              prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: isReadOnly
                  ? Icon(Icons.visibility_off, color: colorScheme.onSurface.withValues(alpha: 0.5))
                  : null,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
