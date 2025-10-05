import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<String> _favoriteSongs = [];
  List<String> _historySongs = [];

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteSongs = prefs.getStringList("favorites") ?? [];
      _historySongs = prefs.getStringList("history") ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Thư viện"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧡 Yêu thích
              const Text(
                "❤️ Thư viện yêu thích",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _favoriteSongs.isEmpty
                  ? const Text("Chưa có bài hát yêu thích nào...")
                  : Column(
                      children: _favoriteSongs.map((title) {
                        return ListTile(
                          leading:
                              const Icon(Icons.favorite, color: Colors.red),
                          title: Text(title),
                          subtitle: Text("Đã thêm vào yêu thích"),
                          trailing: const Icon(Icons.play_arrow),
                          onTap: () {
                            // Chuyển sang PlayerScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(
                                  songList: [
                                    {"title": title, "file": "$title.mp3"}
                                  ],
                                  currentIndex: 0,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
              const Divider(height: 30, thickness: 1),

              // ⏱️ Lịch sử nghe nhạc
              const Text(
                "🕒 Lịch sử nghe nhạc",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _historySongs.isEmpty
                  ? const Text("Bạn chưa nghe bài hát nào gần đây.")
                  : Column(
                      children: _historySongs.map((title) {
                        return ListTile(
                          leading: const Icon(Icons.history,
                              color: Colors.deepPurple),
                          title: Text(title),
                          subtitle: const Text("Nghe gần đây"),
                        );
                      }).toList(),
                    ),
              const Divider(height: 30, thickness: 1),

              // 🎶 Playlist
              const Text(
                "🎶 Playlists",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading:
                    const Icon(Icons.queue_music, color: Colors.deepPurple),
                title: const Text("Danh sách phát của bạn"),
                subtitle: const Text("Chưa có nội dung..."),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("🎶 Tính năng Playlists sắp ra mắt!")));
                },
              ),

              const Divider(height: 30, thickness: 1),

              // 👥 Following
              const Text(
                "👥 Following",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.deepPurple),
                title: const Text("Nghệ sĩ bạn theo dõi"),
                subtitle: const Text("Tính năng đang phát triển..."),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("👥 Tính năng Following sắp ra mắt!")));
                },
              ),

              const Divider(height: 30, thickness: 1),

              // 💿 Albums
              const Text(
                "💿 Albums",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.album, color: Colors.deepPurple),
                title: const Text("Album của bạn"),
                subtitle: const Text("Tính năng đang phát triển..."),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("💿 Tính năng Albums sắp ra mắt!")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
