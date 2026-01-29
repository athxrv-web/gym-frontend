import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const String baseUrl = 'https://gym-backend-4qbx.onrender.com/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, dynamic>> getPaymentStats() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/payments/stats/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      return {};
    }
  }
}