import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, String>> _likedSongs = [];

  // Danh sách nhạc có sẵn trong app
  final List<Map<String, String>> _allSongs = const [
    {"title": "Bài hát 1", "file": "song1.m4a"},
    {"title": "Bài hát 2", "file": "song2.m4a"},
    {"title": "Bài hát 3", "file": "song3.mp3"},
  ];

  @override
  void initState() {
    super.initState();
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedTitles =
        prefs.getKeys().where((key) => prefs.getBool(key) == true);

    setState(() {
      _likedSongs = _allSongs
          .where((song) => likedTitles.contains(song["title"]))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💜 Thư viện yêu thích"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _likedSongs.isEmpty
          ? const Center(
              child: Text(
                "Chưa có bài hát nào được yêu thích 😢",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _likedSongs.length,
              itemBuilder: (context, index) {
                final song = _likedSongs[index];
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.pink),
                  title: Text(song["title"]!),
                  subtitle: Text(song["file"]!),
                  trailing:
                      const Icon(Icons.play_arrow, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          songList: _likedSongs,
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
