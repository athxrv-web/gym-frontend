import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "2026. ", 
              style: TextStyle(color: Colors.grey, fontSize: 12)
            ),
            TextSpan(
              text: "CREATED_by_", 
              style: TextStyle(color: Colors.grey, fontSize: 12)
            ),
            TextSpan(
              text: "ATHARV", 
              style: TextStyle(
                color: AppColors.electricBlue, 
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontSize: 14,
                shadows: [Shadow(color: AppColors.electricBlue, blurRadius: 10)]
              )
            ),
          ],
        ),
      ),
    );
  }
}