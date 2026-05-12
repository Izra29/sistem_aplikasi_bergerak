import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ─── GANTI URL INI dengan URL server PHP Anda ────────────────────────────
  static const String baseUrl = 'https://yourdomain.com'; // contoh: 'https://api.nuruliman.id'
  // ─────────────────────────────────────────────────────────────────────────

  /// Login ke server PHP.
  /// Kembalikan [LoginResult] berisi role dan pesan error jika gagal.
  static Future<LoginResult> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user': username.trim(),
          'pass': password.trim(),
          'login': '1',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          // Simpan sesi ke SharedPreferences (setara $_SESSION PHP)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', data['role'] ?? '');
          await prefs.setString('username', data['username'] ?? '');
          await prefs.setString('id', data['id']?.toString() ?? '');
          await prefs.setString('jenis_asrama', data['jenis_asrama'] ?? '');

          return LoginResult(success: true, role: data['role'] ?? '');
        } else {
          return LoginResult(success: false, error: data['message'] ?? 'Username atau Password salah!');
        }
      } else {
        return LoginResult(success: false, error: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return LoginResult(success: false, error: 'Gagal terhubung ke server. Periksa koneksi internet.');
    }
  }

  /// Logout — hapus sesi (setara session_destroy PHP)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Opsional: beritahu server untuk invalidasi sesi
    try {
      await http.post(Uri.parse('$baseUrl/api/logout.php'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Ambil role yang sedang login
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? '';
  }

  /// Ambil username yang sedang login
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final role = await getRole();
    return role.isNotEmpty;
  }
}

class LoginResult {
  final bool success;
  final String role;
  final String error;

  LoginResult({required this.success, this.role = '', this.error = ''});
}