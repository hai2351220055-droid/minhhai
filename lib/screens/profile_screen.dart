import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ✅ đúng import
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import '../auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? currentUser;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadAvatar();
  }

  // 🔹 Lấy thông tin user đang đăng nhập
  Future<void> _loadUserInfo() async {
    final users = await AuthService.getAllUsers();
    if (AuthService.currentUser != null) {
      final user = users.firstWhere(
        (u) => u['username'] == AuthService.currentUser,
        orElse: () => {},
      );
      setState(() {
        currentUser = user;
      });
    }
  }

  // 🔹 Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final tempImage = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.name;
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', savedImage.path);

      setState(() {
        _avatarImage = savedImage;
      });
    }
  }

  // 🔹 Tải ảnh đại diện đã lưu
  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString('avatar_path');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _avatarImage = File(path);
      });
    }
  }

  // 🔹 Xóa ảnh đại diện
  Future<void> _deleteAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('avatar_path');
    setState(() {
      _avatarImage = null;
    });
  }

  // 🔹 Xuất PDF
  Future<void> _exportPDF() async {
    if (currentUser == null) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Thông tin người dùng",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("👤 Tên đăng nhập: ${currentUser!['username']}"),
            pw.Text("📧 Gmail: ${currentUser!['email'] ?? 'Chưa có'}"),
            pw.Text("📱 Số điện thoại: ${currentUser!['phone'] ?? 'Chưa có'}"),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/user_info.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Xuất PDF thành công: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 Thông tin của tôi"),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: currentUser == null
          ? const Center(child: Text("Không tìm thấy thông tin user"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 🔹 Ảnh đại diện
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : null,
                      child: _avatarImage == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Nút chọn ảnh
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Chọn ảnh đại diện"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),

                    // Nút xóa ảnh
                    if (_avatarImage != null)
                      TextButton.icon(
                        onPressed: _deleteAvatar,
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text("Xóa ảnh đại diện",
                            style: TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 30),

                    // Thông tin người dùng
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👤 Tên đăng nhập: ${currentUser!['username']}"),
                          Text(
                              "📧 Gmail: ${currentUser!['email'] ?? 'Chưa có'}"),
                          Text(
                              "📱 Số điện thoại: ${currentUser!['phone'] ?? 'Chưa có'}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: _exportPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Xuất PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
