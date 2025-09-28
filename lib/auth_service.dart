import 'database_helper.dart';

class AuthService {
  static String? currentUser;

  /// Đăng ký tài khoản mới
  static Future<bool> register(String username, String password) async {
    try {
      await DatabaseHelper.insertUser(username, password);
      return true; // ✅ đăng ký thành công
    } catch (e) {
      print("❌ Lỗi khi đăng ký: $e");
      return false; // ❌ thất bại (thường do username đã tồn tại)
    }
  }

  /// Đăng nhập
  static Future<bool> login(String username, String password) async {
    final user = await DatabaseHelper.getUser(username, password);
    if (user != null) {
      currentUser = username; // ✅ Lưu tên user hiện tại
      return true;
    }
    return false;
  }

  /// Lấy danh sách tất cả user
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await DatabaseHelper.getAllUsers();
  }

  /// Đăng xuất
  static void logout() {
    currentUser = null;
  }
}
