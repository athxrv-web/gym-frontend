import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Import AuthService

class PaymentService {
  // Use global URL
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> getPaymentStats() async {
    // ⚠️ FIX: Seedha AuthService se token mango (Key mismatch nahi hoga)
    final token = await AuthService.getToken();
    
    if (token == null) return {};

    final url = Uri.parse('$baseUrl/payments/stats/');
    try {
      final response = await http.get(
        url, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' // Ye sahi tha, bas token null aa raha tha pehle
        }
      );
      
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      return {};
    }
  }
}