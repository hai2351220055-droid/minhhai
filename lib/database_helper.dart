import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;

  // 🧱 Tên bảng và các cột
  static const String tableUser = "users";
  static const String columnId = "id";
  static const String columnUsername = "username";
  static const String columnPassword = "password";
  static const String columnEmail = "email";
  static const String columnPhone = "phone";
  static const String columnAvatar = "avatar_path";
  static const String columnCreatedAt = "created_at";

  // 🔹 Lấy database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 🔹 Khởi tạo database
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "music_app.db");

    return await openDatabase(
      path,
      version: 6, // tăng version khi sửa cấu trúc
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS $tableUser");
        await _createTable(db);
      },
    );
  }

  // 🔹 Tạo bảng user
  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT UNIQUE,
        $columnPassword TEXT,
        $columnEmail TEXT,
        $columnPhone TEXT,
        $columnAvatar TEXT,
        $columnCreatedAt TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    // 🧩 User mặc định admin (mật khẩu đã mã hóa)
    final hashedAdminPass =
        sha256.convert(utf8.encode("123")).toString();

    await db.insert(tableUser, {
      columnUsername: "admin",
      columnPassword: hashedAdminPass,
      columnEmail: "admin@gmail.com",
      columnPhone: "0123456789",
      columnAvatar: "",
      columnCreatedAt: DateTime.now().toString(),
    });
  }

  // 🔹 Thêm user mới (mật khẩu được mã hóa SHA-256)
  static Future<int> insertUser(
    String username,
    String password,
    String email,
    String phone,
    String avatarPath,
  ) async {
    final db = await database;

    // 🔐 Mã hóa mật khẩu
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    return await db.insert(
      tableUser,
      {
        columnUsername: username,
        columnPassword: hashedPassword,
        columnEmail: email,
        columnPhone: phone,
        columnAvatar: avatarPath,
        columnCreatedAt: DateTime.now().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  // 🔹 Lấy toàn bộ user
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    final users = await db.query(tableUser, orderBy: "$columnId DESC");
    return users;
  }

  // 🔹 Tìm user đăng nhập (so sánh mật khẩu đã được hash)
  static Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await database;

    // 🔐 Hash mật khẩu người dùng nhập vào
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final res = await db.query(
      tableUser,
      where: "$columnUsername = ? AND $columnPassword = ?",
      whereArgs: [username, hashedPassword],
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  // 🔹 Lấy ngày tạo tài khoản
  static Future<String?> getCreatedAt(String username) async {
    final db = await database;
    final result = await db.query(
      tableUser,
      columns: [columnCreatedAt],
      where: "$columnUsername = ?",
      whereArgs: [username],
    );
    if (result.isNotEmpty) return result.first[columnCreatedAt] as String;
    return null;
  }

  // 🔹 Lấy avatar
  static Future<String?> getAvatarPath(String username) async {
    final db = await database;
    final result = await db.query(
      tableUser,
      columns: [columnAvatar],
      where: "$columnUsername = ?",
      whereArgs: [username],
    );
    if (result.isNotEmpty) return result.first[columnAvatar] as String;
    return null;
  }
}
