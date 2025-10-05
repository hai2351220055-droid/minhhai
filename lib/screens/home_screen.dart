import 'package:flutter/material.dart';
import 'player_screen.dart'; // chuyển sang màn hình nghe nhạc chi tiết

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> _songs = const [
    {"title": "Bài hát 1", "file": "song1.m4a"},
    {"title": "Bài hát 2", "file": "song2.m4a"},
    {"title": "Bài hát 3", "file": "song3.mp3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Trình phát nhạc"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.deepPurple),
            title: Text(song["title"]!,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle:
                Text(song["file"]!, style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.play_arrow, color: Colors.deepPurple),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(
                    songList: _songs,
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
