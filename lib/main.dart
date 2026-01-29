import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Ye import zaroori hai
import 'core/app_colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart'; // 2. Dashboard bhi import karo

void main() async {
  // 3. Bindings & Token Check
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // Token check karo
  final isLoggedIn = token != null;

  runApp(MyApp(isLoggedIn: isLoggedIn)); // Status aage bhejo
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atomic Gym Admin',
      
      // GLOBAL THEME (Jo tumne set kiya tha, same hai)
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.electricBlue,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Roboto',
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricBlue,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // 4. Magic Line: Agar logged in ho toh direct Dashboard, nahi toh Welcome
      home: isLoggedIn ? const DashboardScreen() : const WelcomeScreen(),
    );
  }
}