import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHoveringUsuario = false;
  bool _isHoveringEmpresa = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6366F1);
    const Color accentColor = Color(0xFFEC4899);
    const Color backgroundColor = Color(0xFF0F172A);
    const Color textPrimary = Color(0xFFF8FAFC);
    const Color textSecondary = Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPainter(_animationController),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFFF8C42),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 48),
                      const Text(
                        'Descontaí',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: textPrimary,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                      const SizedBox(height: 16),
                      const Text(
                        'Plataforma de produtos locais',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms),
                      const SizedBox(height: 64),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Selecione seu perfil',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _PremiumButton(
                              label: 'Comprador',
                              subtitle: 'Explore ofertas e descontos',
                              icon: Icons.person_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/usuario'),
                              onHover: (hovering) {
                                setState(() => _isHoveringUsuario = hovering);
                              },
                              isHovering: _isHoveringUsuario,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 800.ms)
                                .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 800.ms),
                            const SizedBox(height: 16),
                            _PremiumButton(
                              label: 'Empresa',
                              subtitle: 'Gerencie produtos e ofertas',
                              icon: Icons.business_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.8),
                                ],
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/empresa'),
                              onHover: (hovering) {
                                setState(() => _isHoveringEmpresa = hovering);
                              },
                              isHovering: _isHoveringEmpresa,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 1000.ms)
                                .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: 1000.ms),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 700.ms)
                          .scale(delay: 700.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 48),
                      Text(
                        '© 2025 Descontaí. Todos os direitos reservados.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textSecondary.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 1200.ms),
                      const SizedBox(height: 32),
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
}

class _PremiumButton extends StatefulWidget {
  const _PremiumButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onPressed,
    required this.onHover,
    required this.isHovering,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onPressed;
  final Function(bool) onHover;
  final bool isHovering;

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        widget.onHover(true);
        _scaleController.forward();
      },
      onExit: (_) {
        widget.onHover(false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_scaleController.value * 0.05),
              child: Container(
                constraints: const BoxConstraints(minHeight: 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: widget.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withOpacity(0.4),
                      blurRadius: widget.isHovering ? 25 : 15,
                      spreadRadius: widget.isHovering ? 2 : 0,
                      offset: Offset(0, widget.isHovering ? 8 : 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final center1 = Offset(size.width * 0.2, size.height * 0.3);
    final radius1 = 150 + (animation.value * 50);
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.15),
        const Color(0xFF6366F1).withOpacity(0.05),
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    final center2 = Offset(size.width * 0.8, size.height * 0.7);
    final radius2 = 200 + (animation.value * 30);
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFFEC4899).withOpacity(0.12),
        const Color(0xFFEC4899).withOpacity(0.03),
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
