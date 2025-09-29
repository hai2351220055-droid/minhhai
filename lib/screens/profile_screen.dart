import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

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

  Future<void> _exportPDF() async {
    if (currentUser == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Thông tin người dùng", style: pw.TextStyle(fontSize: 24)),
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
        backgroundColor: Colors.deepPurple,
      ),
      body: currentUser == null
          ? const Center(child: Text("Không tìm thấy thông tin user"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 Tên đăng nhập: ${currentUser!['username']}"),
                  Text("📧 Gmail: ${currentUser!['email'] ?? 'Chưa có'}"),
                  Text(
                    "📱 Số điện thoại: ${currentUser!['phone'] ?? 'Chưa có'}",
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
    );
  }
}
