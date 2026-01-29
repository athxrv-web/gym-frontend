import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/member_service.dart';
import 'user_home_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});
  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _phoneController = TextEditingController();
  final MemberService _memberService = MemberService();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Phone Number required!")));
      return;
    }

    setState(() => _isLoading = true);

    // ✅ PROPER CALL: Backend se pucho
    final userData = await _memberService.getMemberByPhone(phone);

    setState(() => _isLoading = false);

    if (userData != null) {
      // ✅ SUCCESS
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => UserHomeScreen(user: userData))
      );
    } else {
      // ❌ FAIL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member Not Found! Contact Admin."), 
          backgroundColor: Colors.red
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phonelink_lock, size: 80, color: AppColors.electricBlue),
            const SizedBox(height: 20),
            const Text("MEMBER LOGIN", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Enter your registered phone number", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: AppColors.electricBlue),
                hintText: "Phone Number",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("CHECK STATUS", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}