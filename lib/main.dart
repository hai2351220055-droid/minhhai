import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo trước khi chạy async
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Nếu sau này bạn muốn thêm SQLite init thì để ở đây
  // await DatabaseHelper.instance.initDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // ✅ font mặc định dễ nhìn
      ),
      home: const LoginScreen(), // Màn hình mở đầu
    );
  }
}
