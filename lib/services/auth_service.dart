import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Live Backend URL
  static const String baseUrl = "https://gym-backend-4qbx.onrender.com/api";

  static Future<Map<String, dynamic>> login(String emailInput, String password) async {
    print("🔵 LOGIN ATTEMPT: $emailInput");

    try {
      // 1. URL FIX: Screenshot confirm karta hai ki ye '/token/' hai
      final url = Uri.parse('$baseUrl/token/'); 

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': emailInput, // Django default 'username' key maangta hai
          'password': password
        }),
      );

      print("🟡 Status: ${response.statusCode}");
      print("🟡 Body: ${response.body}");

      // ERROR CHECK: Agar HTML (Oops page) aaya
      if (response.body.toString().contains("<")) {
         return {'success': false, 'detail': 'Server Error (HTML received). Path galat hai.'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 2. TOKEN KEY FIX: Screenshot mein 'access' likha tha
        String? token = data['access']; 
        
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          return {'success': true};
        }
      } 
      
      return {'success': false, 'detail': 'Invalid Email or Password'};

    } catch (e) {
      return {'success': false, 'detail': 'Connection Error: $e'};
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}