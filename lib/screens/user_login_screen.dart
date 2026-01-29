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

  Future<void> _checkNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Apna Number daalo bhai!")));
      return;
    }

    setState(() => _isLoading = true);

    // 1. Saare members lao
    final allMembers = await _memberService.getAllMembers();

    setState(() => _isLoading = false);

    // 2. Check karo number hai ya nahi
    try {
      final user = allMembers.firstWhere(
        (m) => m['phone'].toString() == phone,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        // ✅ Mil gaya! Jao Andar
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => UserHomeScreen(user: user))
        );
      } else {
        // ❌ Nahi mila
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Number Not Found! Admin se baat karo."), backgroundColor: AppColors.red)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Error! (Shayad Admin Login chahiye)"), backgroundColor: AppColors.red)
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
                onPressed: _isLoading ? null : _checkNumber,
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