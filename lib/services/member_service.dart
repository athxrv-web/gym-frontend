import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class MemberService {
  // Global URL use karenge
  static const String baseUrl = AuthService.baseUrl;

  // ✅ 1. PROPER MEMBER LOGIN (Token Free)
  Future<Map<String, dynamic>?> getMemberByPhone(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/members/status/check/'); // ✅ Naya URL
      print("🔵 Checking Phone: $phone");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, // ⚠️ No Auth Header Here
        body: jsonEncode({"phone": phone}),
      );

      print("🟡 Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // 🎉 Member Mil Gaya
      } else {
        return null; // ❌ Member Nahi Mila
      }
    } catch (e) {
      print("🔴 Error checking member: $e");
      return null;
    }
  }

  // ✅ 2. GET ALL MEMBERS (For Admin - Secure)
  Future<List<dynamic>> getAllMembers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/members/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('results')) return data['results'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ 3. ADD MEMBER (For Admin - Secure)
  Future<String> addMember(Map<String, dynamic> memberData, XFile? imageFile) async {
    final token = await AuthService.getToken();
    if (token == null) return "Login Required";

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/members/'));
      request.headers.addAll({"Authorization": "Bearer $token"});

      memberData.forEach((key, value) => request.fields[key] = value.toString());

      if (imageFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('profile_image', await imageFile.readAsBytes(), filename: 'photo.jpg'));
        } else {
          request.files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));
        }
      }

      var response = await http.Response.fromStream(await request.send());
      return (response.statusCode == 201 || response.statusCode == 200) ? "SUCCESS" : "Error: ${response.body}";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ✅ 4. DELETE MEMBER (For Admin - Secure)
  Future<bool> deleteMember(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;
      final response = await http.delete(Uri.parse('$baseUrl/members/$id/'), headers: {"Authorization": "Bearer $token"});
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}