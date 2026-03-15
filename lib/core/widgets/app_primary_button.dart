import 'package:flutter/material.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';

/// App-wide primary gradient button used for all main actions.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 32,
    this.loader,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final Widget? loader;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 200.0;
        return SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: _isDisabled
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                  : AppColors.primary,
              boxShadow: _isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: _isDisabled ? null : onPressed,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey('loader'),
                            width: 22,
                            height: 22,
                            child: loader ??
                                CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

