import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 1. Live Render URL
  static const String baseUrl = "https://gym-backend-4qbx.onrender.com/api";

  // Login Function
  static Future<Map<String, dynamic>> login(String emailInput, String password) async {
    print("🔵 ATTEMPTING LOGIN...");
    print("Email Sent: $emailInput");

    try {
      // 2. Endpoint 'login' hai, 'token' nahi
      final response = await http.post(
        Uri.parse('$baseUrl/login/'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': emailInput, // Django default username field maangta hai
          'password': password
        }),
      );

      print("🟡 RESPONSE STATUS: ${response.statusCode}");
      print("🟡 RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body);

      // 3. Backend 'token' return karega, 'access' nahi
      if (response.statusCode == 200 && data['token'] != null) {
        // ✅ Success
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return {'success': true};
      } else {
        // ❌ Fail
        return {
          'success': false,
          'detail': data['detail'] ?? 'Login Failed: ${response.body}'
        };
      }
    } catch (e) {
      print("🔴 CONNECTION ERROR: $e");
      return {'success': false, 'detail': 'Server Error: $e'};
    }
  }

  // Token Getter
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}