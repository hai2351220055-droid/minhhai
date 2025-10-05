import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'auth_service.dart';
import 'user_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int _currentIndex = 0;

  // ✅ Danh sách các tab màn hình
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final username = AuthService.currentUser ?? "Người dùng";

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Music Player"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // ✅ Nếu là admin -> hiển thị nút quản lý user
          if (username == "admin")
            IconButton(
              tooltip: "Danh sách người dùng",
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

      // ✅ Hiển thị màn hình tương ứng tab
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
        type: BottomNavigationBarType.fixed,
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
          ),
        ],
      ),
    );
  }
}
