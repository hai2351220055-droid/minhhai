import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String songTitle;

  const DetailScreen({super.key, required this.songTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(songTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          "🎶 Đang phát: $songTitle",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
