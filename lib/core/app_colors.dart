import 'package:flutter/material.dart';

class AppColors {
  // --- BASIC COLORS ---
  static const Color background = Color(0xFF121212); // Pitch Black
  static const Color surface = Color(0xFF1E1E1E);    // Card Color
  static const Color electricBlue = Color(0xFF00F3FF); // Neon Blue
  static const Color neonPink = Color(0xFFD000FF);   // Cyber Pink
  static const Color gold = Color(0xFFFFD700);       // Gold
  static const Color red = Color(0xFFFF3D00);        // Red
  static const Color green = Color(0xFF00E676);      // Green (Ye zaroori hai)
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  // Aliases
  static const Color neonBlue = electricBlue;
  static const Color cardDark = surface;
}

// --- LEGACY BRIDGE (Ye purane code ko support karta hai) ---
class SpartanColors {
  static const Color background = AppColors.background;
  static const Color cardDark = AppColors.surface;
  static const Color neonBlue = AppColors.electricBlue;
  static const Color gold = AppColors.gold;
  static const Color red = AppColors.red;
  static const Color white = AppColors.white;
  static const Color grey = AppColors.grey;
  
  // 👇 YE LINE MISSING THI, AB ADD KAR DI HAI
  static const Color green = AppColors.green; 
}