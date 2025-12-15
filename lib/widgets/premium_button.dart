import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/premium_theme.dart';

/// Botão Premium com Glassmorphism e Microinterações
class PremiumButton extends StatefulWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final EdgeInsets? padding;

  const PremiumButton({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    this.gradient,
    this.color,
    this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.padding,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isHovering = false;

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
    final gradient = widget.gradient ??
        (widget.color != null
            ? LinearGradient(
                colors: [widget.color!, widget.color!.withOpacity(0.8)],
              )
            : PremiumTheme.primaryGradient);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_scaleController.value * 0.05),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (gradient.colors.first as Color).withOpacity(0.4),
                      blurRadius: _isHovering ? 25 : 15,
                      spreadRadius: _isHovering ? 2 : 0,
                      offset: Offset(0, _isHovering ? 8 : 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading ? null : widget.onPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: widget.padding ??
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: widget.isLoading
                          ? Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.label,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (widget.subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.subtitle!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(0.9),
                                            letterSpacing: 0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
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









