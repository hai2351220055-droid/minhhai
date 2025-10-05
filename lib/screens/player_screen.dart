import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerScreen extends StatefulWidget {
  final List<Map<String, String>> songList;
  final int currentIndex;

  const PlayerScreen({
    super.key,
    required this.songList,
    required this.currentIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLiked = false;
  late int _currentIndex;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _loadSong(widget.songList[_currentIndex]);
    _listenToPlayer();
    _loadLiked();
    _loadComments();
  }

  Map<String, String> get _currentSong => widget.songList[_currentIndex];

  void _listenToPlayer() {
    _positionSub = _player.positionStream.listen((p) {
      setState(() => _position = p);
    });
    _durationSub = _player.durationStream.listen((d) {
      setState(() => _duration = d ?? Duration.zero);
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _loadLiked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked = prefs.getBool(_currentSong["title"]!) ?? false;
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked = !_isLiked;
    });

    // Cập nhật danh sách yêu thích
    prefs.setBool(_currentSong["title"]!, _isLiked);
    List<String> favList = prefs.getStringList("favorites") ?? [];
    if (_isLiked) {
      if (!favList.contains(_currentSong["title"])) {
        favList.add(_currentSong["title"]!);
      }
    } else {
      favList.remove(_currentSong["title"]);
    }
    prefs.setStringList("favorites", favList);
  }

  Future<void> _loadSong(Map<String, String> song) async {
    try {
      await _player.setAsset("assets/music/${song['file']}");
      await _player.play();
      setState(() {
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _addToHistory(song['title']!);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Lỗi phát nhạc: $e")));
    }
  }

  Future<void> _addToHistory(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("history") ?? [];
    history.remove(title);
    history.insert(0, title);
    if (history.length > 10) history = history.sublist(0, 10);
    prefs.setStringList("history", history);
  }

  void _nextSong() {
    final next = (_currentIndex + 1) % widget.songList.length;
    _loadSong(widget.songList[next]);
    setState(() {
      _currentIndex = next;
      _loadLiked();
      _loadComments();
    });
  }

  void _prevSong() {
    final prev =
        (_currentIndex - 1 + widget.songList.length) % widget.songList.length;
    _loadSong(widget.songList[prev]);
    setState(() {
      _currentIndex = prev;
      _loadLiked();
      _loadComments();
    });
  }

  void _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "comments_${_currentSong["title"]}";
    final saved = prefs.getStringList(key) ?? [];
    setState(() => _comments = saved);
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = "comments_${_currentSong["title"]}";
    setState(() {
      _comments.add(text.trim());
    });
    prefs.setStringList(key, _comments);
    _commentController.clear();
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong;

    return Scaffold(
      appBar: AppBar(
        title: Text("🎧 ${song["title"]}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
            ),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/background.jpg",
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Tên bài hát
            Text(
              song["title"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Thanh tiến trình
            ProgressBar(
              progress: _position,
              total: _duration,
              onSeek: (value) => _player.seek(value),
              baseBarColor: Colors.grey[300]!,
              progressBarColor: Colors.deepPurple,
              thumbColor: Colors.deepPurpleAccent,
              timeLabelTextStyle: const TextStyle(fontSize: 14),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position),
                    style: const TextStyle(color: Colors.grey)),
                Text(_formatTime(_duration),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),

            // Nút điều khiển
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    iconSize: 45,
                    color: Colors.deepPurple,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _prevSong),
                IconButton(
                  iconSize: 70,
                  color: Colors.deepPurple,
                  icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle_fill),
                  onPressed: _playPause,
                ),
                IconButton(
                    iconSize: 45,
                    color: Colors.deepPurple,
                    icon: const Icon(Icons.skip_next),
                    onPressed: _nextSong),
              ],
            ),
            const SizedBox(height: 25),

            Text("🎵 ${song['file']}",
                style: const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),

            // 💬 Bình luận
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("💬 Bình luận",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            for (var comment in _comments)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person,
                        color: Color.fromARGB(255, 162, 200, 66)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(comment)),
                  ],
                ),
              ),

            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addComment(_commentController.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 128, 192, 59)),
                  child: const Text("Gửi"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
