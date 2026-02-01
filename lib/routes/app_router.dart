import 'package:flutter/material.dart';
import '../mvvm/views/bottom_nav.dart';
import '../mvvm/views/splash/splash_view.dart';

/// Application routes
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String splash = '/splash';
  static const String bottomNav = '/bottom-nav';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case home:
        // Home route shows the bottom navigation with Home/Add/Profile tabs
        return MaterialPageRoute(builder: (_) => const BottomNav());
      case bottomNav:
        return MaterialPageRoute(builder: (_) => const BottomNav());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
