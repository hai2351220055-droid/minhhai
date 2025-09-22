import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner góc phải
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Chủ đề màu xanh
        scaffoldBackgroundColor: Colors.black, // Màu nền mặc định
      ),
      home: const LoginScreen(), // ✅ Màn hình đầu tiên: Đăng nhập
    );
  }
}
