import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Tên bảng và cột
  static const String tableUser = "users";
  static const String columnId = "id";
  static const String columnUsername = "username";
  static const String columnPassword = "password";

  // Hàm lấy database (nếu đã có thì mở, chưa có thì tạo mới)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Khởi tạo DB
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "music_app.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tạo bảng user
        await db.execute('''
          CREATE TABLE $tableUser (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUsername TEXT UNIQUE,
            $columnPassword TEXT
          )
        ''');

        // ✅ Thêm user mặc định admin
        await db.insert(tableUser, {
          columnUsername: "admin",
          columnPassword: "123",
        });
      },
    );
  }

  // Thêm user mới
  static Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert(
      tableUser,
      {columnUsername: username, columnPassword: password},
      conflictAlgorithm:
          ConflictAlgorithm.rollback, // báo lỗi nếu trùng username
    );
  }

  // Lấy tất cả user
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(tableUser);
  }

  // Tìm user theo username/password (login)
  static Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final res = await db.query(
      tableUser,
      where: "$columnUsername = ? AND $columnPassword = ?",
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }
}
