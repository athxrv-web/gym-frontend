import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // ImagePicker ke liye
import 'package:flutter/foundation.dart'; // kIsWeb ke liye
import 'auth_service.dart';

class MemberService {
  // Live Render URL
  final String baseUrl = "https://gym-backend-4qbx.onrender.com/api";

  // 📋 GET ALL MEMBERS
  Future<List<dynamic>> getAllMembers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/members/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token", // ⚠️ 'Bearer' ki jagah 'Token' use karo
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend pagination use kar raha hai toh 'results' key check karo
        if (data is Map && data.containsKey('results')) {
          return data['results'];
        } else if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("GET Error: $e");
      return [];
    }
  }

  // ➕ ADD MEMBER (Multipart Request for Image)
  Future<String> addMember(Map<String, dynamic> memberData, XFile? imageFile) async {
    final token = await AuthService.getToken();
    if (token == null) return "Login Expired! Please login again.";

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/members/'));

      // Headers
      request.headers.addAll({
        "Authorization": "Token $token", // ⚠️ 'Bearer' -> 'Token'
      });

      // Fields (Sabko String mein convert karke bhejo)
      memberData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Image Handling
      if (imageFile != null) {
        if (kIsWeb) {
          var bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'profile_image',
            bytes,
            filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'profile_image',
            imageFile.path,
          ));
        }
      }

      // Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "SUCCESS";
      } else {
        return "Server Error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Network Error: $e";
    }
  }

  // 🗑️ DELETE MEMBER (ID is now String/UUID)
  Future<bool> deleteMember(String id) async { // ⚠️ 'int' ko 'String' kar diya
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/members/$id/'),
        headers: {
          "Authorization": "Token $token", // ⚠️ 'Bearer' -> 'Token'
        },
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}