import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/core/constants/app_images.dart';
import 'package:flutter/services.dart';
import '../../../routes/app_router.dart';

/// Splash screen view with video and premium fallback
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/videos/splash_screen.mp4',
      );
      await _controller!.initialize();

      if (mounted && _controller != null) {
        setState(() {
          _isInitialized = true;
        });

        // Play video
        await _controller!.play();
        _controller!.setLooping(false);

        // Listen for video completion
        _controller!.addListener(_videoListener);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        // Navigate to home after a short delay if video fails
        Timer(const Duration(seconds: 3), () {
          _navigateToHome();
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null &&
        _controller!.value.position >= _controller!.value.duration) {
      // Video finished, navigate to home
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent for full screen effect
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background - Premium Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),

          // Video Layer
          if (_isInitialized && !_hasError)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

          // Loading / Fallback Layer
          if (!_isInitialized || _hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(AppImages.logo, height: 80, width: 80),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_hasError)
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
