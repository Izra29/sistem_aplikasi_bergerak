// lib/screens/portal_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'orangtua_screen.dart';
import 'pengurus_screen.dart';
import 'admin_keuangan_screen.dart';

class PortalScreen extends StatelessWidget {
  final String         username;
  final List<UserRole> roles;

  const PortalScreen({super.key, required this.username, required this.roles});

  IconData _iconForRole(String role) {
    switch (role) {
      case 'admin':      return Icons.laptop_mac_rounded;
      case 'superadmin': return Icons.admin_panel_settings_rounded;
      case 'bendahara':  return Icons.account_balance_wallet_rounded;
      case 'guru':       return Icons.cast_for_education_rounded;
      case 'walikelas':  return Icons.menu_book_rounded;
      case 'pengurus':   return Icons.home_rounded;
      case 'kurikulum':  return Icons.calendar_today_rounded;
      case 'piket':      return Icons.assignment_turned_in_rounded;
      case 'kesenian':   return Icons.music_note_rounded;
      case 'kesehatan':  return Icons.favorite_rounded;
      case 'kebersihan': return Icons.cleaning_services_rounded;
      case 'peralatan':  return Icons.inventory_2_rounded;
      case 'dewan':      return Icons.account_balance_rounded;
      case 'pimpinan':   return Icons.star_rounded;
      case 'orangtua':   return Icons.family_restroom_rounded;
      default:           return Icons.badge_rounded;
    }
  }

  String _desc(UserRole r) {
    if (r.role == 'pengurus' && r.namaKobong != null) return 'Kobong: ${r.namaKobong}';
    if (r.role == 'walikelas' && r.kelas != null)     return 'Kelas: ${r.kelas}';
    return 'Akses Fitur ${_cap(r.role)}';
  }

  String _cap(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  Future<void> _pilihRole(BuildContext ctx, UserRole r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_role', r.role);
    if (r.kobongId    != null) await prefs.setString('session_kobong_id',    r.kobongId!);
    if (r.jenisAsrama != null) await prefs.setString('session_jenis_asrama', r.jenisAsrama!);
    if (!ctx.mounted) return;
    Widget screen;
    switch (r.role) {
      case 'orangtua': screen = const OrangtuaScreen(); break;
      case 'pengurus':  screen = const PengurusScreen();       break;
      case 'admin':
      case 'superadmin':
      case 'bendahara':  screen = const AdminKeuanganScreen(); break;
      default:         screen = const OrangtuaScreen();
    }
    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext ctx) async {
    await AuthService.clearSession();
    if (!ctx.mounted) return;
    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF0f5132), Color(0xFF198754)],
                      ),
                    ),
                    child: Column(children: [
                      Text('Pilih Akses Masuk',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                      const SizedBox(height: 6),
                      Text('Halo, ${_cap(username)}. Mau login sebagai apa?',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.75), fontSize: 14)),
                    ]),
                  ),

                  // Daftar role
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      if (roles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(children: [
                            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
                            const SizedBox(height: 12),
                            Text('Akun Anda belum memiliki jabatan.\nHubungi Admin.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF666666))),
                          ]),
                        )
                      else
                        ...roles.asMap().entries.map((e) => _RoleCard(
                          role:  e.value,
                          icon:  _iconForRole(e.value.role),
                          desc:  _desc(e.value),
                          onTap: () => _pilihRole(context, e.value),
                        ).animate().fadeIn(delay: (e.key * 80).ms).slideX(begin: 0.2, end: 0)),

                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                        label: Text('Logout / Ganti Akun',
                            style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ]),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole     role;
  final IconData     icon;
  final String       desc;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.icon, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFeeeeee)),
            ),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF198754).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF198754), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.role.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF333333))),
                  const SizedBox(height: 2),
                  Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF777777))),
                ],
              )),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFaaaaaa)),
            ]),
          ),
        ),
      ),
    );
  }
}
