import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class UserHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 🛡️ Data Safety (Crash Proofing)
    final name = user['name'] ?? "Warrior";
    final expiryStr = user['membership_end_date'] ?? DateTime.now().toIso8601String();
    final plan = user['membership_type'] ?? "Monthly";
    
    // 📅 Date Logic
    int daysLeft = 0;
    bool isExpired = true;
    try {
      final expiry = DateTime.parse(expiryStr);
      daysLeft = expiry.difference(DateTime.now()).inDays;
      isExpired = daysLeft < 0;
    } catch (e) {
      print("Date Error: $e");
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text("MY PROFILE", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Photo
            Container(
              height: 120, width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isExpired ? Colors.red : AppColors.electricBlue, width: 4),
              ),
              child: ClipOval(
                child: (user['profile_image'] != null)
                  ? Image.network(
                      user['profile_image'], fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Icon(Icons.person, size: 60, color: Colors.grey),
                    )
                  : const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text(user['phone'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),

            // 2. Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isExpired ? Colors.red : AppColors.green),
              ),
              child: Column(
                children: [
                  Text(isExpired ? "MEMBERSHIP EXPIRED" : "MEMBERSHIP ACTIVE", 
                    style: TextStyle(color: isExpired ? Colors.red : AppColors.green, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isExpired ? "Please Pay Fees" : "$daysLeft Days Left",
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Valid till: ${expiryStr.split('T')[0]}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Info Tiles
            _buildInfoTile("Current Plan", plan, Icons.fitness_center),
            _buildInfoTile("Joining Date", user['join_date'] ?? "-", Icons.calendar_today),
            _buildInfoTile("Weight", "${user['weight'] ?? '-'} Kg", Icons.monitor_weight),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.electricBlue),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}