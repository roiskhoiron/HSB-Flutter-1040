import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme Provider untuk manage Dark Mode
final themeProvider = StateProvider<bool>((ref) {
  // Default: Light Mode (false)
  return false;
});
