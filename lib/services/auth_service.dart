// lib/services/auth_service.dart
// ============================================================
// Service untuk komunikasi dengan backend PHP (login/logout)
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class AuthService {
  // ── Simpan data sesi ke SharedPreferences ─────────────────
  static Future<void> saveSession({
    required String id,
    required String username,
    required String role,
    String? kobongId,
    String? jenisAsrama,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id',       id);
    await prefs.setString('session_username', username);
    await prefs.setString('session_role',     role);
    if (kobongId    != null) await prefs.setString('session_kobong_id',    kobongId);
    if (jenisAsrama != null) await prefs.setString('session_jenis_asrama', jenisAsrama);
  }

  // ── Baca sesi yang tersimpan ──────────────────────────────
  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id':           prefs.getString('session_id'),
      'username':     prefs.getString('session_username'),
      'role':         prefs.getString('session_role'),
      'kobong_id':    prefs.getString('session_kobong_id'),
      'jenis_asrama': prefs.getString('session_jenis_asrama'),
    };
  }

  // ── Hapus sesi (logout) ───────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Cek apakah user sudah login ───────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id') != null;
  }

  // ── LOGIN: Kirim POST ke backend PHP ─────────────────────
  // Backend harus mengembalikan JSON seperti:
  // { "status": "ok", "id": "1", "username": "admin", "roles": [...] }
  // atau { "status": "error", "message": "..." }
  static Future<LoginResult> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.loginUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user': username.trim(),
          'pass': password.trim(),
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          final List roles = data['roles'] ?? [];

          // Simpan data user ke lokal
          await saveSession(
            id:           data['id'].toString(),
            username:     data['username'],
            role:         roles.isNotEmpty ? roles[0]['role'] : '',
            jenisAsrama:  roles.isNotEmpty ? roles[0]['jenis_asrama'] : null,
            kobongId:     roles.isNotEmpty ? roles[0]['kobong_id']?.toString() : null,
          );

          return LoginResult(
            success:  true,
            roles:    roles.map((r) => UserRole.fromJson(r)).toList(),
            userId:   data['id'].toString(),
            username: data['username'],
          );
        } else {
          return LoginResult(
            success: false,
            message: data['message'] ?? 'Username atau Password salah!',
          );
        }
      } else {
        return LoginResult(success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Gagal terhubung ke server. Periksa koneksi internet Anda.\n($e)',
      );
    }
  }
}

// ── Model hasil login ─────────────────────────────────────────
class LoginResult {
  final bool       success;
  final String?    message;
  final List<UserRole> roles;
  final String?    userId;
  final String?    username;

  LoginResult({
    required this.success,
    this.message,
    this.roles    = const [],
    this.userId,
    this.username,
  });
}

// ── Model data role/jabatan user ─────────────────────────────
class UserRole {
  final String  role;
  final String? kobongId;
  final String? namaKobong;
  final String? jenisAsrama;
  final String? kelas;

  UserRole({
    required this.role,
    this.kobongId,
    this.namaKobong,
    this.jenisAsrama,
    this.kelas,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      role:        json['role']        ?? '',
      kobongId:    json['kobong_id']?.toString(),
      namaKobong:  json['nama_kobong'],
      jenisAsrama: json['jenis_asrama'],
      kelas:       json['kelas'],
    );
  }
}
