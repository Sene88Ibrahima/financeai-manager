import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final ConfettiController controller;
  final AlignmentGeometry alignment;
  final BlastDirectionality blastDirectionality;
  final int numberOfParticles;
  final double minBlastForce;
  final double maxBlastForce;

  const ConfettiOverlay({
    Key? key,
    required this.child,
    required this.controller,
    this.alignment = Alignment.topCenter,
    this.blastDirectionality = BlastDirectionality.explosive,
    this.numberOfParticles = 20,
    this.minBlastForce = 10,
    this.maxBlastForce = 30,
  }) : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: widget.alignment,
          child: ConfettiWidget(
            confettiController: widget.controller,
            blastDirectionality: widget.blastDirectionality,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: widget.numberOfParticles,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.red,
              Colors.cyan,
            ],
            strokeWidth: 1,
            strokeColor: Colors.white,
            minBlastForce: widget.minBlastForce,
            maxBlastForce: widget.maxBlastForce,
            createParticlePath: (size) {
              // Create custom particle shapes
              final path = Path();
              final random = Random();
              final shapeType = random.nextInt(3);
              
              switch (shapeType) {
                case 0: // Star
                  return _drawStar(size);
                case 1: // Circle
                  path.addOval(Rect.fromCircle(
                    center: Offset(size.width / 2, size.height / 2),
                    radius: size.width / 2,
                  ));
                  return path;
                default: // Rectangle
                  path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
                  return path;
              }
            },
          ),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = 360 / numberOfPoints;
    final halfDegreesPerStep = degreesPerStep / 2;
    
    path.moveTo(size.width, halfWidth);

    for (int i = 1; i <= numberOfPoints; i++) {
      final degrees = degreesPerStep * i;
      final radians = degrees * pi / 180;
      final x = halfWidth + externalRadius * cos(radians);
      final y = halfWidth + externalRadius * sin(radians);
      path.lineTo(x, y);

      final internalDegrees = degrees - halfDegreesPerStep;
      final internalRadians = internalDegrees * pi / 180;
      final internalX = halfWidth + internalRadius * cos(internalRadians);
      final internalY = halfWidth + internalRadius * sin(internalRadians);
      path.lineTo(internalX, internalY);
    }
    
    path.close();
    return path;
  }
}

class CelebrationButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CelebrationButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<CelebrationButton> createState() => _CelebrationButtonState();
}

class _CelebrationButtonState extends State<CelebrationButton>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    _confettiController.play();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width ?? 200,
                height: widget.height ?? 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.backgroundColor ?? Theme.of(context).primaryColor,
                      (widget.backgroundColor ?? Theme.of(context).primaryColor)
                          .withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? Theme.of(context).primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleTap,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }
}

// Success animation widget
class SuccessAnimation extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    Key? key,
    required this.message,
    this.onComplete,
  }) : super(key: key);

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    _confetti.play();
    await Future.delayed(const Duration(seconds: 2));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _checkAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CheckmarkPainter(
                    progress: _checkAnimation.value,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 50,
          gravity: 0.1,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.lightGreen,
            Colors.greenAccent,
            Colors.yellow,
            Colors.orange,
          ],
        ),
      ],
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    
    if (progress > 0) {
      path.moveTo(startX, startY);
      
      if (progress <= 0.5) {
        final midProgress = progress * 2;
        path.lineTo(
          startX + (size.width * 0.2 * midProgress),
          startY + (size.height * 0.2 * midProgress),
        );
      } else {
        path.lineTo(
          startX + size.width * 0.2,
          startY + size.height * 0.2,
        );
        
        final endProgress = (progress - 0.5) * 2;
        path.lineTo(
          startX + size.width * 0.2 + (size.width * 0.35 * endProgress),
          startY + size.height * 0.2 - (size.height * 0.35 * endProgress),
        );
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}