import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/premium_theme.dart';

/// Background Premium com efeitos animados
class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showAnimatedCircles;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showAnimatedCircles = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = PremiumTheme.getBackgroundColor(isDark);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  PremiumTheme.backgroundColor,
                  const Color(0xFF1E293B),
                  PremiumTheme.backgroundColor,
                ]
              : [
                  const Color(0xFFF1F5F9), // Cinza muito claro
                  Colors.white,
                  const Color(0xFFF1F5F9), // Cinza muito claro
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (showAnimatedCircles)
            Positioned.fill(
              child: CustomPaint(
                painter: _BackgroundPainter(isDark: isDark),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Círculos de fundo estáticos
    final center1 = Offset(size.width * 0.2, size.height * 0.3);
    final radius1 = 180.0;
    paint.shader = LinearGradient(
      colors: [
        PremiumTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
        PremiumTheme.primaryColor.withOpacity(isDark ? 0.03 : 0.02),
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    final center2 = Offset(size.width * 0.8, size.height * 0.7);
    final radius2 = 220.0;
    paint.shader = LinearGradient(
      colors: [
        PremiumTheme.accentColor.withOpacity(isDark ? 0.1 : 0.06),
        PremiumTheme.accentColor.withOpacity(isDark ? 0.02 : 0.01),
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _BackgroundPainter) {
      return oldDelegate.isDark != isDark;
    }
    return false;
  }
}



