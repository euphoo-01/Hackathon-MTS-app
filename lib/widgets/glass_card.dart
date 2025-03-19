import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:healarm/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final double blurStrength;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool hasShadow;
  final Gradient? gradient;
  final bool expandWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.blurStrength = 10.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.hasShadow = false,
    this.gradient,
    this.expandWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: expandWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: AppTheme.blurRadius, sigmaY: AppTheme.blurRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? AppTheme.glassMorphismGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: AppTheme.textDarkColor,
                fontFamily: 'Inter',
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: AppTheme.textDarkColor.withOpacity(0.8),
                    ),
                    hintStyle: TextStyle(
                      color: AppTheme.textDarkColor.withOpacity(0.5),
                    ),
                  ),
                  iconTheme: IconThemeData(
                    color: AppTheme.textDarkColor,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BentoGridItem extends StatelessWidget {
  final Widget child;
  final int columnSpan;
  final int rowSpan;
  final Gradient? gradient;
  final bool isGlass;

  const BentoGridItem({
    super.key,
    required this.child,
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.gradient,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isGlass) {
      return GlassCard(
        gradient: gradient,
        child: child,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient ?? AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );
    }
  }
}
