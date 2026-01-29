import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class MemberIdCard extends StatelessWidget {
  final Map<String, dynamic> member; // Pura member data
  final VoidCallback onPrint;
  final VoidCallback onWhatsapp; // 🆕 WhatsApp Action
  final VoidCallback onDelete;   // 🆕 Delete Action

  const MemberIdCard({
    super.key,
    required this.member,
    required this.onPrint,
    required this.onWhatsapp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Data nikal lo safely
    final name = member['name'] ?? "Unknown";
    final phone = member['phone'] ?? "N/A";
    final plan = member['membership_type'] ?? "Monthly";
    final expiry = member['membership_end_date'] ?? "N/A";
    
    // Status Check (Agar expiry date nikal gayi toh Red)
    bool isExpired = false;
    try {
      if (expiry != "N/A") {
        isExpired = DateTime.parse(expiry).isBefore(DateTime.now());
      }
    } catch (e) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired ? AppColors.red : AppColors.electricBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // 1. Photo Section
          Container(
            height: 70, width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isExpired ? AppColors.red : AppColors.electricBlue, width: 2),
              image: member['profile_image'] != null 
                ? DecorationImage(image: NetworkImage(member['profile_image']), fit: BoxFit.cover)
                : null,
            ),
            child: member['profile_image'] == null 
              ? const Icon(Icons.person, color: Colors.grey, size: 30) 
              : null,
          ),
          const SizedBox(width: 15),

          // 2. Details Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(plan, style: const TextStyle(color: AppColors.electricBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    if(isExpired)
                       Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("EXPIRED", style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),

          // 3. Action Buttons (WhatsApp, Print, Delete)
          Column(
            children: [
              // WhatsApp
              IconButton(
                icon: const Icon(Icons.message, color: Colors.green),
                onPressed: onWhatsapp,
                tooltip: "WhatsApp Reminder",
              ),
              // Print
              IconButton(
                icon: const Icon(Icons.print, color: AppColors.electricBlue),
                onPressed: onPrint,
                tooltip: "Print Receipt",
              ),
            ],
          )
        ],
      ),
    );
  }
}