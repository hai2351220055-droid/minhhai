import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'auth_service.dart'; // ✅ để lấy thông tin user đang đăng nhập

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = AuthService.currentUser ?? "Người dùng";

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Music Player"),
        actions: [
          IconButton(
            tooltip: "Đăng xuất",
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout(); // reset trạng thái user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "✅ Xin chào, $username!\nChào mừng bạn đến ứng dụng nghe nhạc!",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
