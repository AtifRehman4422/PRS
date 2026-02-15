import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/animations/fade_in_slide.dart';
import 'package:propertyrent/core/theme/theme_provider.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';
import 'package:propertyrent/mvvm/viewmodels/auth_viewmodel.dart';
import 'package:propertyrent/mvvm/views/profile/my_profile_view.dart';
import 'package:propertyrent/mvvm/views/profile/favorites_view.dart';
import 'package:propertyrent/mvvm/views/profile/my_ads/my_ads_view.dart';
import 'package:propertyrent/mvvm/views/auth/login_view.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginView(),
    );
  }

  void _showInviteSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const appLink = 'https://propertyrent.example';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invite a Friend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share the app link with your friends.',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appLink,
                      style: TextStyle(color: colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(const ClipboardData(text: appLink));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                    label: const Text('Copy', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateUsSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int rating = 5;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rate Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < rating;
                    return IconButton(
                      onPressed: () => setState(() => rating = i + 1),
                      icon: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thanks for rating $rating stars!')),
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We respect your privacy. This app stores basic information needed to provide services. '
                  'No personal data is shared with third parties without your consent. '
                  'Images and listings you upload are visible to other users. '
                  'You can request data removal at any time via Contact Us.',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8), height: 1.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data We Collect',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Account details, contact information, and property listing content you provide.',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Contact',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'For questions or requests, use the Contact Us option in the app.',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How would you like to contact us?',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContactOption(
                  context,
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.green,
                  onTap: () {},
                ),
                _buildContactOption(
                  context,
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: Colors.green.shade800,
                  onTap: () {},
                ),
                _buildContactOption(
                  context,
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.blue,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
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

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    final themeMode = ref.read(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose Light or Dark for the whole app',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.light_mode, color: Colors.orange.shade700),
              title: const Text('Light'),
              subtitle: const Text('Light theme for the app'),
              trailing: isDark ? null : const Icon(Icons.check, color: AppColors.primary),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode, color: Colors.indigo.shade300),
              title: const Text('Dark'),
              subtitle: const Text('Dark theme for the app'),
              trailing: isDark ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with curved background (shows user photo & name when logged in)
            _buildHeader(context, size, user),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    if (user != null) ...[
                      FadeInSlide(
                        delay: 0.1,
                        child: _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          subtitle: 'Edit personal details',
                          color1: Colors.blue,
                          color2: Colors.blue.shade800,
                          onTap: () => _navigateToPage(context, const MyProfileView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInSlide(
                        delay: 0.2,
                        child: _buildMenuItem(
                          context,
                          icon: Icons.grid_view_rounded,
                          title: 'My Ads',
                          subtitle: 'Manage your properties',
                          color1: AppColors.primary,
                          color2: AppColors.primary.withValues(alpha: 0.8),
                          onTap: () => _navigateToPage(context, const MyAdsView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FadeInSlide(
                      delay: 0.3,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.favorite_border,
                        title: 'Favorites',
                        subtitle: 'Your saved properties',
                        color1: Colors.red,
                        color2: Colors.red.shade800,
                        onTap: () => _navigateToPage(context, const FavoritesView()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 0.35,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.brightness_6_outlined,
                        title: 'Appearance',
                        subtitle: 'Light / Dark mode',
                        color1: Colors.indigo,
                        color2: Colors.indigo.shade800,
                        onTap: () => _showThemeSheet(context, ref),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 0.4,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.support_agent,
                        title: 'Contact Us',
                        subtitle: 'Get help & support',
                        color1: Colors.green,
                        color2: Colors.green.shade800,
                        onTap: () => _showContactOptions(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 0.5,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.share,
                        title: 'Invite Friend',
                        subtitle: 'Share app with friends',
                        color1: AppColors.primary,
                        color2: Colors.red.shade800,
                        onTap: () => _showInviteSheet(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 0.6,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.star_outline,
                        title: 'Rate Us',
                        subtitle: 'Rate app on store',
                        color1: Colors.orange,
                        color2: Colors.orange.shade800,
                        onTap: () => _showRateUsSheet(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 0.7,
                      child: _buildMenuItem(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our policies',
                        color1: Colors.blue,
                        color2: Colors.blue.shade800,
                        onTap: () => _showPrivacyPolicySheet(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Version Card
                    FadeInSlide(
                      delay: 0.8,
                      child: Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _gradientIcon(
                                    Icons.info_outline,
                                    color1: Colors.orange,
                                    color2: Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'App Version',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '1.1.1',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Latest',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login / Logout Button
                    FadeInSlide(
                      delay: 0.9,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: user != null
                              ? () async {
                                  await ref.read(authRepositoryProvider).signOut();
                                }
                              : () => _showLoginSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: user != null
                                ? Colors.grey.shade700
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                user != null ? Icons.logout : Icons.login,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                user != null ? 'Logout' : 'Login',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size, AuthUser? user) {
    return Container(
      width: double.infinity,
      height: size.height * 0.28,
      child: Stack(
        children: [
          // Curved background
          Positioned.fill(child: CustomPaint(painter: _ProfileHeaderPainter())),
          // Decorative circles
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  FadeInSlide(
                    delay: 0.0,
                    child: Text(
                      user != null ? user.displayLabel : 'Profile',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user != null) ...[
                    FadeInSlide(
                      delay: 0.1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: user.hasPhoto
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: !user.hasPhoto
                              ? _gradientIcon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                    ),
                  ] else ...[
                    FadeInSlide(
                      delay: 0.1,
                      child: GestureDetector(
                        onTap: () => _showLoginSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: _gradientIcon(Icons.person, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInSlide(
                      delay: 0.2,
                      child: GestureDetector(
                        onTap: () => _showLoginSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Login to your account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color1,
    required Color color2,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color1.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _gradientIcon(icon, color1: color1, color2: color2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: _gradientIcon(
                    Icons.chevron_right,
                    color1: Colors.grey,
                    color2: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for profile header curve
class _ProfileHeaderPainter extends CustomPainter {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
