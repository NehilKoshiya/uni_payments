import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass container used for the gateway tiles and the result
/// card. Built on [BackdropFilter] so it composes with whatever sits
/// behind it.
class GlassCard extends StatelessWidget {
  /// Create a [GlassCard].
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.tint,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
  });

  /// Wrapped content.
  final Widget child;

  /// Inner padding around [child].
  final EdgeInsetsGeometry padding;

  /// Corner radius.
  final double borderRadius;

  /// Optional brand tint blended into the frosted base.
  final Color? tint;

  /// Optional tap handler — used to make a card behave like a button.
  final VoidCallback? onTap;

  /// Override the border colour. Defaults to a subtle white-on-dark line.
  final Color? borderColor;

  /// Override the border thickness. Defaults to 1.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    const base = Color(0x14FFFFFF); // white @ 8%
    final resolvedTint = tint;
    final fill = resolvedTint == null
        ? base
        : Color.alphaBlend(resolvedTint.withValues(alpha: 0.08), base);
    final resolvedBorder = borderColor ?? Colors.white.withValues(alpha: 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: fill,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: resolvedBorder, width: borderWidth),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
