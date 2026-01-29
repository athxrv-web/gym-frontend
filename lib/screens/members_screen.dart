import 'dart:io'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import '../core/app_colors.dart';
import '../services/member_service.dart';
import '../services/pdf_service.dart';
import '../widgets/member_id_card.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final MemberService _memberService = MemberService();
  
  // Data Variables
  List<dynamic> _allMembers = [];
  List<dynamic> _filteredMembers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // 📝 FORM CONTROLLERS
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();
  final _ageController = TextEditingController(text: "25");
  final _weightController = TextEditingController(text: "70");
  final _heightController = TextEditingController(text: "170");
  
  String _selectedGender = "M";
  DateTime _selectedDate = DateTime.now(); 

  // Image Picker
  XFile? _selectedImage; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // 🔄 LOAD DATA
  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final data = await _memberService.getAllMembers();
    if (mounted) {
      setState(() { 
        _allMembers = data; 
        _filteredMembers = data; 
        _isLoading = false; 
      });
    }
  }

  // 🗑️ DELETE LOGIC (UPDATED: String ID for UUID)
  Future<void> _deleteMember(String id) async { // ⚠️ Change: int -> String
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Delete Warrior?", style: TextStyle(color: Colors.white)),
        content: const Text("Cannot be undone.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
            child: const Text("YES")
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _memberService.deleteMember(id);
      _loadMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member Deleted!"), backgroundColor: Colors.red));
      }
    }
  }

  // 🔍 SEARCH LOGIC
  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _allMembers.where((m) => 
        m['name'].toString().toLowerCase().contains(query.toLowerCase()) || 
        m['phone'].toString().contains(query)
      ).toList();
    });
  }

  // 💬 WHATSAPP LOGIC
  Future<void> _openWhatsApp(String phone, String name) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), ''); 
    if (cleanPhone.length > 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
    final url = Uri.parse("https://wa.me/91$cleanPhone?text=Hello $name, Your gym fees is due.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
      }
    }
  }

  // 📸 IMAGE PICKER
  void _showImageSourcePicker(BuildContext context, StateSetter setDialogState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue), 
            title: const Text("Camera", style: TextStyle(color: Colors.white)), 
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera, setDialogState); }
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.green), 
            title: const Text("Gallery", style: TextStyle(color: Colors.white)), 
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery, setDialogState); }
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, StateSetter setDialogState) async {
    final XFile? photo = await _picker.pickImage(source: source, maxWidth: 600, imageQuality: 50);
    if (photo != null) setDialogState(() => _selectedImage = photo);
  }

  // 📅 DATE PICKER
  Future<void> _pickDate(BuildContext context, StateSetter setDialogState) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!)
    );
    if (picked != null) setDialogState(() => _selectedDate = picked);
  }

  // ➕ ADD MEMBER
  Future<void> _addMember() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name & Phone Required!")));
      return;
    }

    // Date Logic
    final joinStr = _selectedDate.toString().split(' ')[0];
    final expiryDate = _selectedDate.add(const Duration(days: 30));
    final expiryStr = expiryDate.toString().split(' ')[0];
    
    // Unique Email Hack for Backend
    String uniqueEmail = "user_${DateTime.now().millisecondsSinceEpoch}_${_phoneController.text.substring(0,2)}@gym.com";

    final newMember = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "membership_type": "MONTHLY",
      "membership_fee": _feeController.text.isEmpty ? "0" : _feeController.text,
      "join_date": joinStr,
      "membership_start_date": joinStr,
      "membership_end_date": expiryStr,
      "age": _ageController.text.isEmpty ? "25" : _ageController.text,
      "height": _heightController.text.isEmpty ? "170" : _heightController.text,
      "weight": _weightController.text.isEmpty ? "70" : _weightController.text,
      "gender": _selectedGender,
      "email": uniqueEmail,
    };

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adding Member...")));

    final result = await _memberService.addMember(newMember, _selectedImage);

    if (result == "SUCCESS") {
      _loadMembers();
      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Member Added Successfully!"), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text("Failed ⚠️", style: TextStyle(color: Colors.red)),
            content: SingleChildScrollView(
              child: Text(result, style: const TextStyle(color: Colors.white70)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
            ],
          )
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear(); _phoneController.clear(); _feeController.clear();
    _ageController.text = "25"; _weightController.text = "70"; _heightController.text = "170";
    setState(() { _selectedImage = null; _selectedDate = DateTime.now(); });
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const Icon(Icons.camera_alt, color: AppColors.electricBlue);
    if (kIsWeb) {
      return Image.network(_selectedImage!.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(_selectedImage!.path), fit: BoxFit.cover);
    }
  }

  // ✨ DIALOG UI
  void _showAddDialog() {
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("NEW WARRIOR", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showImageSourcePicker(context, setDialogState), 
                  child: CircleAvatar(
                    radius: 40, 
                    backgroundColor: AppColors.background, 
                    child: ClipOval(child: SizedBox(width: 80, height: 80, child: _buildImagePreview()))
                  )
                ),
                const SizedBox(height: 10),
                const Text("Add Photo", style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 15),

                _buildInput(_nameController, "Name", Icons.person),
                const SizedBox(height: 10),
                _buildInput(_phoneController, "Phone", Icons.phone, isNumber: true),
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.electricBlue),
                    const SizedBox(width: 10),
                    Text("Joined: ${_selectedDate.toString().split(' ')[0]}", style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _pickDate(context, setDialogState), 
                      child: const Text("CHANGE", style: TextStyle(color: AppColors.electricBlue))
                    )
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _buildInput(_ageController, "Age", Icons.cake, isNumber: true)),
                    const SizedBox(width: 5),
                    Expanded(child: _buildInput(_weightController, "Kg", Icons.monitor_weight, isNumber: true)),
                    const SizedBox(width: 5),
                    Expanded(child: _buildInput(_heightController, "Cm", Icons.height, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Gender", labelStyle: TextStyle(color: Colors.grey)),
                  items: ["M", "F", "O"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setDialogState(() => _selectedGender = v!),
                ),
                const SizedBox(height: 10),

                _buildInput(_feeController, "Fee Paid (₹)", Icons.money, isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: _addMember, 
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue), 
              child: const Text("SAVE", style: TextStyle(color: Colors.black))
            ),
          ],
        );
      }
    ));
  }
  
  Widget _buildInput(TextEditingController c, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.electricBlue),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.electricBlue)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog, 
        label: const Text("ADD NEW"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.electricBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMembers,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Warrior...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.electricBlue),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) => MemberIdCard(
                  member: _filteredMembers[index],
                  onPrint: () => PdfService.generateReceipt(_filteredMembers[index]),
                  onWhatsapp: () => _openWhatsApp(
                    _filteredMembers[index]['phone'].toString(), 
                    _filteredMembers[index]['name'].toString()
                  ),
                  // ⚠️ CRITICAL FIX: Ensure ID is passed as String
                  onDelete: () => _deleteMember(_filteredMembers[index]['id'].toString()),
                ),
              ),
          ),
        ],
      ),
    );
  }
}