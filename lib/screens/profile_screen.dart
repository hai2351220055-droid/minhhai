import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // ⏰ format ngày giờ
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
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

  // 🔹 Lấy thông tin user hiện tại
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

  // 🔹 Chọn ảnh đại diện
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

  // 🔹 Tải lại ảnh đại diện đã lưu
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

  // 🔹 Xuất PDF có logo + tiếng Việt + thời gian đầy đủ
  Future<void> _exportPDF() async {
    if (currentUser == null) return;

    final pdf = pw.Document();

    // ✅ Font tiếng Việt
    final fontData =
        await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldData =
        await rootBundle.load("assets/fonts/roboto/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldData);

    // ✅ Logo
    final logoFile = File('assets/images/dau.jpg');
    pw.MemoryImage? logoImage;
    if (await logoFile.exists()) {
      logoImage = pw.MemoryImage(await logoFile.readAsBytes());
    }

    // ✅ Lấy ngày tạo + tính số ngày dùng
    final createdAt = currentUser!['created_at'];
    DateTime? createdDate;
    int usedDays = 0;
    String formattedCreatedAt = "Không xác định";

    if (createdAt != null && createdAt is String) {
      createdDate = DateTime.tryParse(createdAt);
      if (createdDate != null) {
        usedDays = DateTime.now().difference(createdDate).inDays;
        formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(createdDate);
      }
    }

    // ✅ Ảnh đại diện
    pw.Widget? avatarWidget;
    if (_avatarImage != null && await _avatarImage!.exists()) {
      final imageBytes = await _avatarImage!.readAsBytes();
      final image = pw.MemoryImage(imageBytes);
      avatarWidget = pw.Center(
        child: pw.Container(
          width: 100,
          height: 100,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
          ),
        ),
      );
    }

    // ✅ Trang PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("Thông tin người dùng",
                  style: pw.TextStyle(
                      font: boldTtf, fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (logoImage != null) pw.Image(logoImage, width: 80, height: 80),
              pw.SizedBox(height: 15),
              if (avatarWidget != null) avatarWidget,
              pw.SizedBox(height: 25),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("👤 Tên đăng nhập: ${currentUser!['username']}",
                        style: pw.TextStyle(font: ttf, fontSize: 16)),
                    pw.Text("📧 Gmail: ${currentUser!['email'] ?? 'Chưa có'}",
                        style: pw.TextStyle(font: ttf, fontSize: 16)),
                    pw.Text("📱 Số điện thoại: ${currentUser!['phone'] ?? 'Chưa có'}",
                        style: pw.TextStyle(font: ttf, fontSize: 16)),
                    pw.Text("📅 Ngày tạo tài khoản: $formattedCreatedAt",
                        style: pw.TextStyle(font: ttf, fontSize: 16)),
                    pw.Text("⏰ Đã sử dụng: $usedDays ngày",
                        style: pw.TextStyle(font: ttf, fontSize: 16)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text("Cảm ơn bạn đã sử dụng ứng dụng của Minh Hải ❤️",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    // ✅ Lưu file PDF
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/user_info.pdf");
    await file.writeAsBytes(await pdf.save());

    // ✅ Hiển thị PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Xuất PDF thành công: ${file.path}")),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysSinceRegister = 0;
    String formattedDate = "Không xác định";
    DateTime? createdDate;

    if (currentUser?['created_at'] != null &&
        currentUser!['created_at'] is String) {
      createdDate = DateTime.tryParse(currentUser!['created_at']);
      if (createdDate != null) {
        daysSinceRegister = DateTime.now().difference(createdDate).inDays;
        formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(createdDate);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 Thông tin của tôi"),
        backgroundColor: Colors.white,
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
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage:
                          _avatarImage != null ? FileImage(_avatarImage!) : null,
                      child: _avatarImage == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Chọn ảnh đại diện"),
                    ),
                    if (_avatarImage != null)
                      TextButton.icon(
                        onPressed: _deleteAvatar,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text("Xóa ảnh đại diện",
                            style: TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👤 Tên đăng nhập: ${currentUser!['username']}"),
                          Text("📧 Gmail: ${currentUser!['email'] ?? 'Chưa có'}"),
                          Text("📱 Số điện thoại: ${currentUser!['phone'] ?? 'Chưa có'}"),
                          Text("📅 Ngày tạo tài khoản: $formattedDate"),
                          Text("⏰ Đã sử dụng: $daysSinceRegister ngày"),
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
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
