import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/try_on_avatar_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String tryOnAvatar = '/try-on-avatar';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case tryOnAvatar:
        return MaterialPageRoute(builder: (_) => const TryOnAvatarScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
