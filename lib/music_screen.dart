import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'auth_service.dart';
import 'user_list_screen.dart'; // ✅ màn hình quản lý user
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart'; // ✅ màn hình Tôi

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int _currentIndex = 0; // tab hiện tại

  // ✅ Gọi 4 màn hình
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(), // 👤 màn hình "Tôi"
  ];

  @override
  Widget build(BuildContext context) {
    final username = AuthService.currentUser ?? "Người dùng";

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Music Player"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (username == "admin")
            IconButton(
              tooltip: "Danh sách user",
              icon: const Icon(Icons.supervised_user_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserListScreen(),
                  ),
                );
              },
            ),

          // ✅ Nút đăng xuất
          IconButton(
            tooltip: "Đăng xuất",
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // ✅ Hiển thị tab theo _currentIndex
      body: _screens[_currentIndex],

      // ✅ Thanh điều hướng dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // hiển thị đủ 4 tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Tôi",
          ), // 👤 thêm tab Tôi
        ],
      ),
    );
  }
}
