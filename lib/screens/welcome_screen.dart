import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';
import 'user_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColors.background],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.electricBlue, width: 3),
                    boxShadow: [
                      BoxShadow(color: AppColors.electricBlue.withOpacity(0.5), blurRadius: 20)
                    ],
                  ),
                  child: const Icon(Icons.fitness_center, size: 60, color: AppColors.electricBlue),
                ),
                const SizedBox(height: 40),
                
                const Text(
                  "ATOMIC GYM",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 2
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Choose your role",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 50),

                // ADMIN BUTTON
                _buildButton(
                  context, 
                  "I AM ADMIN", 
                  Icons.admin_panel_settings, 
                  AppColors.electricBlue, 
                  const LoginScreen()
                ),
                const SizedBox(height: 20),

                // MEMBER BUTTON
                _buildButton(
                  context, 
                  "I AM MEMBER", 
                  Icons.person, 
                  Colors.white, 
                  const UserLoginScreen() // Ye file abhi banayenge
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, Color color, Widget nextScreen) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              text, 
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}