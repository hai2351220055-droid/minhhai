import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến ứng dụng nghe nhạc!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
