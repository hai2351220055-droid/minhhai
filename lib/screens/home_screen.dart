import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentSong;
  bool _isPlaying = false;

  // Danh sách nhạc trong assets/music/
  final List<Map<String, String>> _songs = [
    {"title": "Bài hát 1", "file": "song1.m4a"},
    {"title": "Bài hát 2", "file": "song2.m4a"},
    {"title": "Bài hát 3", "file": "song3.mp3"},
  ];

  // Hàm phát / tạm dừng nhạc
  Future<void> _playSong(String file) async {
    try {
      if (_currentSong == file && _isPlaying) {
        await _player.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _player.play(AssetSource("music/$file"));
        setState(() {
          _currentSong = file;
          _isPlaying = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Lỗi phát nhạc: $e")));
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
          final isPlayingThis = _currentSong == song["file"] && _isPlaying;

          return ListTile(
            leading: Icon(
              isPlayingThis ? Icons.pause_circle : Icons.play_circle,
              color: Colors.deepPurple,
              size: 40,
            ),
            title: Text(
              song["title"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(song["file"]!),
            onTap: () => _playSong(song["file"]!),
          );
        },
      ),
    );
  }
}
