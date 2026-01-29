import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/member_service.dart';
import 'members_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MemberService _memberService = MemberService();
  
  // 🔢 Real Stats Variables
  int _totalMembers = 0;
  int _activeMembers = 0;
  int _pendingFeesCount = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  // 🧮 JADOI CALCULATION LOGIC
  Future<void> _calculateStats() async {
    final members = await _memberService.getAllMembers();
    
    int total = members.length;
    int active = 0;
    int pending = 0;
    double revenue = 0.0;
    final now = DateTime.now();

    for (var m in members) {
      // 1. Revenue Jodo (String se Number banao)
      if (m['membership_fee'] != null) {
        revenue += double.tryParse(m['membership_fee'].toString()) ?? 0.0;
      }

      // 2. Expiry Check Karo
      if (m['membership_end_date'] != null) {
        try {
          DateTime expiry = DateTime.parse(m['membership_end_date']);
          if (expiry.isAfter(now)) {
            active++; // Abhi time bacha hai
          } else {
            pending++; // Expire ho gaya (Fees Pending)
          }
        } catch (e) {
          pending++; // Agar date galat hai toh bhi pending maano
        }
      }
    }

    if (mounted) {
      setState(() {
        _totalMembers = total;
        _activeMembers = active;
        _pendingFeesCount = pending;
        _totalRevenue = revenue;
        _isLoading = false;
      });
    }
  }

  // 🚪 Logout Function
  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("DASHBOARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _handleLogout, 
            icon: const Icon(Icons.logout, color: AppColors.red),
            tooltip: "Logout",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Welcome Header
            const Text("WELCOME BOSS,", style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1.2)),
            const SizedBox(height: 5),
            const Text("ATOMIC GYM", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // 📊 STATS CARDS GRID
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.electricBlue))
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, // 2 Cards ek line mein
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3, // Card ka size adjust karne ke liye
                  children: [
                    _buildStatCard("TOTAL MEMBERS", "$_totalMembers", Icons.group, AppColors.electricBlue),
                    _buildStatCard("TOTAL REVENUE", "₹${_totalRevenue.toStringAsFixed(0)}", Icons.currency_rupee, Colors.green),
                    _buildStatCard("ACTIVE MEMBERS", "$_activeMembers", Icons.fitness_center, Colors.orange),
                    _buildStatCard("PENDING FEES", "$_pendingFeesCount", Icons.warning, AppColors.red),
                  ],
                ),
            
            const SizedBox(height: 30),
            
            // 🚀 QUICK ACTIONS HEADER
            const Text("QUICK ACTIONS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Add Member Screen
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen()));
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("MANAGE MEMBERS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🎨 Custom Card Design
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}