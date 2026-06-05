// lib/screens/login_screen.dart
// Tampilan persis seperti web index.php
// Menggunakan: google_fonts, flutter_animate, shared_preferences

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import 'portal_screen.dart';
import 'orangtua_screen.dart';
import 'pengurus_screen.dart';
import 'admin_keuangan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool  _isLoading   = false;
  bool  _showPass    = false;
  bool  _hasError    = false;
  String _errorMsg   = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (await AuthService.isLoggedIn()) {
      final s = await AuthService.getSession();
      if (!mounted) return;
      _goByRole(s['role'] ?? '');
    }
  }

  void _goByRole(String role) {
    if (!mounted) return;
    Widget screen;
    switch (role) {
      case 'admin':
      case 'superadmin':
      case 'bendahara':     screen = const AdminKeuanganScreen(); break;
      case 'orangtua':     screen = const OrangtuaScreen();      break;
      case 'pengurus': screen = const PengurusScreen(); break;
      default:         screen = const LoginScreen();    return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _doLogin() async {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() { _hasError = true; _errorMsg = 'Username dan Password tidak boleh kosong!'; });
      return;
    }
    setState(() { _isLoading = true; _hasError = false; });

    final result = await AuthService.login(_userCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (result.success) {
      if (result.roles.length == 1) {
        _goByRole(result.roles.first.role);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => PortalScreen(username: result.username ?? '', roles: result.roles),
        ));
      }
    } else {
      setState(() { _hasError = true; _errorMsg = result.message ?? 'Username atau Password salah!'; });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background hijau zamrud ──────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                colors: [Color(0xFF0a3622), Color(0xFF146c43)],
              ),
            ),
            child: CustomPaint(painter: _DiamondPainter(), size: Size.infinite),
          ),

          // ── Glow kiri atas (kuning) ───────────────────────
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: const Offset(-80, -80),
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFffc107).withOpacity(0.15),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          // ── Glow kanan bawah (hijau cerah) ───────────────
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset: const Offset(80, 80),
              child: Container(
                width: 450, height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF38ef7d).withOpacity(0.10),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          // ── Card login ───────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _buildCard()
                    .animate()
                    .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.3, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border:       Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 45, offset: const Offset(0, 25)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.mosque_rounded, size: 62, color: Color(0xFF0f5132)),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'NURUL IMAN',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w800,
              fontSize: 22, letterSpacing: 2,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistem Informasi Akademik & Keuangan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.7), fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Error alert
          if (_hasError)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMsg,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ).animate().shakeX(duration: 400.ms),

          // Input username
          _inputField(controller: _userCtrl, icon: Icons.person_rounded, hint: 'Username'),
          const SizedBox(height: 18),

          // Input password
          Container(
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
              border:       Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller:  _passCtrl,
              obscureText: !_showPass,
              style:       const TextStyle(color: Colors.white, fontSize: 16),
              onSubmitted: (_) => _doLogin(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.shield_rounded, color: Colors.white.withOpacity(0.7)),
                suffixIcon: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.6)),
                  onPressed: () => setState(() => _showPass = !_showPass),
                ),
                hintText:  'Password',
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.6)),
                border:    InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tombol masuk
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _doLogin,
              style: ElevatedButton.styleFrom(
                padding:     EdgeInsets.zero,
                shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation:   8,
                shadowColor: const Color(0xFFffc107).withOpacity(0.4),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient:     const LinearGradient(colors: [Color(0xFFffc107), Color(0xFFe0a800)]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2.5))
                      : Text(
                    'MASUK SISTEM',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0b3d24), fontWeight: FontWeight.w800,
                      fontSize: 15, letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            '© ${DateTime.now().year} Pondok Pesantren Nurul Iman\nBy Karya Santri',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.45), fontSize: 11, height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
        border:       Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller:  controller,
        style:       const TextStyle(color: Colors.white, fontSize: 16),
        autocorrect: false,
        onSubmitted: (_) => _doLogin(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          hintText:   hint,
          hintStyle:  GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.6)),
          border:     InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}

// ── Pola diamond di background ────────────────────────────────
class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withOpacity(0.04);
    final p2 = Paint()..color = Colors.white.withOpacity(0.02);
    const tile = 80.0;

    for (double y = 0; y < size.height + tile; y += tile) {
      for (double x = 0; x < size.width + tile; x += tile) {
        final cx = x + tile / 2;
        final cy = y + tile / 2;

        final diamond = Path()
          ..moveTo(cx,            cy - tile / 2)
          ..lineTo(cx + tile / 2, cy)
          ..lineTo(cx,            cy + tile / 2)
          ..lineTo(cx - tile / 2, cy)
          ..close();
        canvas.drawPath(diamond, p1);

        final rect = Path()
          ..addRect(Rect.fromLTWH(x, y, tile, tile));
        canvas.drawPath(rect, p2);
      }
    }
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => false;
}
