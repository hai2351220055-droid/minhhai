class AuthService {
  static final Map<String, String> _users = {
    "admin": "123", // Tài khoản mặc định
  };

  static String? currentUser;

  static bool register(String username, String password) {
    if (_users.containsKey(username)) return false;
    _users[username] = password;
    return true;
  }

  static bool login(String username, String password) {
    if (_users[username] == password) {
      currentUser = username; // Lưu lại user đang đăng nhập
      return true;
    }
    return false;
  }

  static void logout() {
    currentUser = null;
  }
}
