import 'package:flutter/material.dart';
import 'package:propertyrent/core/constants/app_images.dart';

/// Custom loader: spinning ring (gumta hua) with logo image in the center.
class LogoLoader extends StatefulWidget {
  const LogoLoader({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 1000),
  });

  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<LogoLoader> createState() => _LogoLoaderState();
}

class _LogoLoaderState extends State<LogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LoaderRingPainter(
                strokeWidth: widget.strokeWidth,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            child: Image.asset(
              AppImages.logo,
              width: widget.size * 0.55,
              height: widget.size * 0.55,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoaderRingPainter extends CustomPainter {
  _LoaderRingPainter({required this.strokeWidth, required this.color});

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const sweepAngle = 4.71; // ~75% of circle (radians), gap = loader look
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
