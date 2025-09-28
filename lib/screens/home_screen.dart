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

  // Danh sách nhạc (nằm trong assets/music/)
  final List<Map<String, String>> _songs = [
    {"title": "Bài hát 1", "file": "song1.mp3"},
    {"title": "Bài hát 2", "file": "song2.mp3"},
  ];

  // Hàm phát nhạc
  Future<void> _playSong(String file) async {
    if (_currentSong == file && _isPlaying) {
      // Nếu đang phát thì pause
      await _player.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // Phát nhạc mới (đúng đường dẫn assets/music/)
      await _player.play(AssetSource("music/$file"));
      setState(() {
        _currentSong = file;
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose(); // Giải phóng tài nguyên khi thoát
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
