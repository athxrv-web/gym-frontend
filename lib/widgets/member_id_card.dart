import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class MemberIdCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onPrint;
  final VoidCallback onWhatsapp;
  final VoidCallback onDelete; // ✅ Ye ab use hoga

  const MemberIdCard({
    super.key,
    required this.member,
    required this.onPrint,
    required this.onWhatsapp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = member['name'] ?? "Unknown";
    final phone = member['phone'] ?? "N/A";
    final plan = member['membership_type'] ?? "Monthly";
    final expiry = member['membership_end_date'] ?? "N/A";
    
    // Status Check
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
          color: isExpired ? Colors.red : AppColors.electricBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // 1. Photo Section (Safe Image Loading)
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isExpired ? Colors.red : AppColors.electricBlue, width: 2),
            ),
            child: ClipOval(
              child: member['profile_image'] != null 
                ? Image.network(
                    member['profile_image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
                  )
                : const Icon(Icons.person, color: Colors.grey, size: 30),
            ),
          ),
          const SizedBox(width: 15),

          // 2. Details Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(plan, style: const TextStyle(color: AppColors.electricBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    if(isExpired)
                       Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("EXPIRED", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),

          // 3. Action Buttons (WhatsApp, Print, DELETE ADDED)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WhatsApp
              IconButton(
                icon: const Icon(Icons.message, color: Colors.green, size: 20),
                onPressed: onWhatsapp,
                tooltip: "WhatsApp",
              ),
              // Print
              IconButton(
                icon: const Icon(Icons.print, color: AppColors.electricBlue, size: 20),
                onPressed: onPrint,
                tooltip: "Print",
              ),
              // 🔴 Delete Button (Added)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                tooltip: "Delete Member",
              ),
            ],
          )
        ],
      ),
    );
  }
}