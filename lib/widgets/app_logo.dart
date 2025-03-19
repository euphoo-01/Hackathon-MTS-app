import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 24.0,
    this.withText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/LOGO1024x1024.png',
          width: size,
          height: size,
        ),
        if (withText) ...[
          const SizedBox(width: 8),
          Text(
            'with MTC',
            style: TextStyle(
              color: textColor ?? Theme.of(context).primaryColor,
              fontSize: size * 0.75,
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
} 