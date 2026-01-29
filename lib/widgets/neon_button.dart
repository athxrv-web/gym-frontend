import 'package:flutter/material.dart';
import '../core/app_colors.dart'; // Ensure ye import ho

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const NeonButton({
    super.key, 
    required this.text, 
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Agar color nahi mila to default Cyan use karega
    final btnColor = color ?? AppColors.electricBlue; 

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: btnColor.withOpacity(0.1), // Halka background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: btnColor, width: 2), // Solid Border
            boxShadow: [
              BoxShadow(
                color: btnColor.withOpacity(0.4), // Simple Glow
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: btnColor, blurRadius: 10)
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}