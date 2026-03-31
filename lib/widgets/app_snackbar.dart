import 'package:flutter/material.dart';

import '../theme/premium_theme.dart';

class AppSnackBar {
  static void success(BuildContext context, String message) {
    _show(context, message, PremiumTheme.successColor);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, PremiumTheme.errorColor);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
