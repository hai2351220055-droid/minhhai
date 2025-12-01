import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  final List<Map<String, dynamic>> _genres = const [
    {"title": "Hip Hop & Rap", "color": Colors.purple, "icon": Icons.mic_none},
    {"title": "Bolero", "color": Colors.orange, "icon": Icons.music_note},
    {"title": "Trữ tình", "color": Colors.pink, "icon": Icons.favorite},
    {"title": "Pop", "color": Colors.amber, "icon": Icons.headphones},
    {"title": "Electronic", "color": Colors.teal, "icon": Icons.speaker},
    {"title": "R&B", "color": Colors.indigo, "icon": Icons.audiotrack},
    {"title": "Party", "color": Colors.deepOrange, "icon": Icons.local_bar},
    {"title": "Chill", "color": Colors.blueAccent, "icon": Icons.spa},
    {"title": "Workout", "color": Colors.green, "icon": Icons.fitness_center},
    {"title": "Techno", "color": Colors.purpleAccent, "icon": Icons.equalizer},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 70, 177),

        // 🔵 tiêu đề + icon màu xanh dương
        title: const Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Khám phá nhạc",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 Thanh tìm kiếm
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.blue), // 🔵 icon search
                  hintText: "Tìm kiếm bài hát, nghệ sĩ, album...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "🎶 Thể loại nhạc",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // GRID THỂ LOẠI
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];

                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Tính năng '${genre["title"]}' đang phát triển...",
                        ),
                      ));
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: genre["color"].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            genre["icon"],
                            color: genre["color"],
                            size: 40,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            genre["title"],
                            style: TextStyle(
                              fontSize: 16,
                              color: genre["color"],
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
