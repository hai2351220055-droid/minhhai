import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Tên bảng và cột
  static const String tableUser = "users";
  static const String columnId = "id";
  static const String columnUsername = "username";
  static const String columnPassword = "password";
  static const String columnEmail = "email";
  static const String columnPhone = "phone";

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
      version: 2, // 🔥 tăng version để cập nhật cấu trúc DB
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 🔥 Xóa bảng cũ khi nâng version (tránh lỗi thiếu cột)
        await db.execute("DROP TABLE IF EXISTS $tableUser");
        await _createTable(db);
      },
    );
  }

  // Hàm tạo bảng user
  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT UNIQUE,
        $columnPassword TEXT,
        $columnEmail TEXT,
        $columnPhone TEXT
      )
    ''');

    // ✅ Thêm user mặc định admin
    await db.insert(tableUser, {
      columnUsername: "admin",
      columnPassword: "123",
      columnEmail: "admin@gmail.com",
      columnPhone: "0123456789",
    });
  }

  // Thêm user mới
  static Future<int> insertUser(
    String username,
    String password,
    String email,
    String phone,
  ) async {
    final db = await database;
    return await db.insert(
      tableUser,
      {
        columnUsername: username,
        columnPassword: password,
        columnEmail: email,
        columnPhone: phone,
      },
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
