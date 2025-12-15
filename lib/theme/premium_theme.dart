import 'package:flutter/material.dart';

/// Design System Premium - 2025
/// Paleta de cores, estilos e componentes reutilizáveis
class PremiumTheme {
  // Paleta de Cores Premium
  static const Color primaryColor = Color(0xFF6366F1); // Indigo elegante
  static const Color secondaryColor = Color(0xFF8B5CF6); // Roxo sofisticado
  static const Color accentColor = Color(0xFFEC4899); // Rosa premium
  static const Color backgroundColor = Color(0xFF0F172A); // Azul escuro profundo
  static const Color surfaceColor = Color(0xFF1E293B); // Superfície escura
  static const Color textPrimary = Color(0xFFF8FAFC); // Branco suave
  static const Color textSecondary = Color(0xFFCBD5E1); // Cinza claro
  static const Color textTertiary = Color(0xFF94A3B8); // Cinza médio
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  // Cores para tema claro
  static const Color lightBackgroundColor = Color(0xFFF1F5F9); // Cinza muito claro
  static const Color lightSurfaceColor = Color(0xFFFFFFFF); // Branco puro
  static const Color lightTextPrimary = Color(0xFF0F172A); // Azul escuro profundo (melhor contraste)
  static const Color lightTextSecondary = Color(0xFF334155); // Cinza escuro (melhor contraste)
  static const Color lightTextTertiary = Color(0xFF475569); // Cinza médio

  // Métodos para obter cores baseado no tema
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundColor : lightBackgroundColor;
  }

  static Color getSurfaceColor(bool isDark) {
    return isDark ? surfaceColor : lightSurfaceColor;
  }

  static Color getTextPrimary(bool isDark) {
    return isDark ? textPrimary : lightTextPrimary;
  }

  static Color getTextSecondary(bool isDark) {
    return isDark ? textSecondary : lightTextSecondary;
  }

  static Color getTextTertiary(bool isDark) {
    return isDark ? textTertiary : lightTextTertiary;
  }

  // Gradientes Premium
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, primaryColor],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor, Color(0xFF1E293B), backgroundColor],
    stops: [0.0, 0.5, 1.0],
  );

  // Estilos de Texto
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: textPrimary,
        height: 1.1,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textTertiary,
        height: 1.4,
      );

  // Decoração de Container Glassmorphism
  static BoxDecoration glassmorphism({
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = 24,
    BuildContext? context,
  }) {
    final isDark = context != null 
        ? Theme.of(context).brightness == Brightness.dark
        : true; // Default para dark
    
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      );
    } else {
      // Tema claro: usar fundo branco sólido com sombra suave
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Borda cinza clara
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  // Decoração de Card Premium
  static BoxDecoration premiumCard({
    Gradient? gradient,
    double borderRadius = 20,
    List<BoxShadow>? customShadows,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: gradient ?? primaryGradient,
      boxShadow: customShadows ??
          [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: -5,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // Input Field Premium
  static InputDecoration premiumInput({
    required String label,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
    BuildContext? context,
  }) {
    final isDark = context != null 
        ? Theme.of(context).brightness == Brightness.dark
        : true; // Default para dark
    
    final textPrimaryColor = getTextPrimary(isDark);
    final textSecondaryColor = getTextSecondary(isDark);
    final textTertiaryColor = getTextTertiary(isDark);
    
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: TextStyle(
        color: textTertiaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: textSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSecondaryColor, size: 22)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark 
          ? Colors.white.withOpacity(0.05)
          : const Color(0xFFF8FAFC), // Fundo cinza muito claro para inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark 
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark 
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: errorColor,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: errorColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}


