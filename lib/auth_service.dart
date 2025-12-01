import 'database_helper.dart';

class AuthService {
  static String? currentUser;

  /// 🧩 Đăng ký tài khoản mới
  static Future<bool> register(
    String username,
    String password,
    String email,
    String phone,
    String avatarPath,
  ) async {
    try {
      // Ở đây KHÔNG hash nữa, DatabaseHelper.insertUser sẽ tự hash
      await DatabaseHelper.insertUser(
        username,
        password,
        email,
        phone,
        avatarPath,
      );
      return true;
    } catch (e) {
      print("❌ Lỗi khi đăng ký: $e");
      return false;
    }
  }

  /// 🔐 Đăng nhập
  static Future<bool> login(String username, String password) async {
    // Gửi password gốc, DatabaseHelper.getUser sẽ tự hash để so sánh
    final user = await DatabaseHelper.getUser(username, password);
    if (user != null) {
      currentUser = username;
      return true;
    }
    return false;
  }

  /// 📋 Lấy toàn bộ danh sách user (để xem hoặc debug)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await DatabaseHelper.getAllUsers();
  }

  /// 🚪 Đăng xuất
  static void logout() {
    currentUser = null;
  }
}
