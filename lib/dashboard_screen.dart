import 'package:flutter/material.dart'; // JANGAN gunakan 'hide Navigator' atau 'as Navigator'
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = '';
  String _namaSapaan = '';
  String _jenisAsrama = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _namaSapaan = prefs.getString('username') ?? '';
      _jenisAsrama = prefs.getString('jenis_asrama') ?? '';
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;

    // Perbaikan navigasi logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // --- Warna tema per role ---
  Color get _roleColor {
    switch (widget.role) {
      case 'admin':       return const Color(0xFF146c43);
      case 'sekretaris':  return const Color(0xFF1565C0);
      case 'kurikulum':   return const Color(0xFF00695C);
      case 'guru':
      case 'walikelas':   return const Color(0xFFE65100);
      case 'piket':       return const Color(0xFF00695C);
      case 'ubudiah':     return const Color(0xFF4A148C);
      case 'keamanan':    return const Color(0xFFC62828);
      case 'kebersihan':  return const Color(0xFF00695C);
      case 'peralatan':   return const Color(0xFF37474F);
      case 'kesehatan':   return const Color(0xFFAD1457);
      case 'kesenian':    return const Color(0xFF6A1B9A);
      case 'rois':        return const Color(0xFF1B5E20);
      default:            return const Color(0xFF146c43);
    }
  }

  String get _roleBadgeLabel {
    switch (widget.role) {
      case 'admin':      return 'ADMIN';
      case 'sekretaris': return 'SEKRETARIS';
      case 'kurikulum':  return 'KURIKULUM';
      case 'guru':       return 'GURU';
      case 'walikelas':  return 'WALI KELAS';
      case 'piket':      return 'PIKET';
      case 'ubudiah':    return 'UBUDIAH';
      case 'keamanan':   return 'KEAMANAN';
      case 'kebersihan': return 'KEBERSIHAN';
      case 'peralatan':  return 'PERALATAN';
      case 'kesehatan':  return 'KESEHATAN';
      case 'kesenian':   return 'KESENIAN';
      case 'rois':       return 'ROIS';
      default:           return widget.role.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _roleColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBg(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Keluar',
                onPressed: _logout,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDashboardContent(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helpers (Tetap sama seperti kode kamu, hanya dirapikan) ---

  Widget _buildAppBarBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_roleColor, _roleColor.withOpacity(0.7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Ahlan Wa Sahlan,', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                _namaSapaan.isEmpty ? _username : _namaSapaan,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(_roleBadgeLabel, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    switch (widget.role) {
      case 'admin':
      case 'superadmin':
      case 'bendahara': return _buildAdminDashboard();
      case 'sekretaris': return _buildSekretarisDashboard();
      case 'kurikulum': return _buildKurikulumDashboard();
      case 'guru':
      case 'walikelas': return _buildGuruDashboard();
      case 'piket': return _buildPiketDashboard();
      case 'ubudiah': return _buildUbudiahDashboard();
      case 'keamanan': return _buildKeamananDashboard();
      case 'kebersihan': return _buildKebersihanDashboard();
      case 'peralatan': return _buildPeralatanDashboard();
      case 'kesehatan': return _buildKesehatanDashboard();
      case 'kesenian': return _buildKesenianDashboard();
      case 'rois': return _buildRoisDashboard();
      default: return _buildAdminDashboard();
    }
  }

  Widget _buildAdminDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Menu Utama'),
        _menuGrid([
          _MenuItem('Data Santri', Icons.people_alt_rounded, const Color(0xFF1565C0)),
          _MenuItem('Keuangan', Icons.account_balance_wallet, const Color(0xFF2E7D32)),
          _MenuItem('Laporan', Icons.bar_chart_rounded, const Color(0xFFE65100)),
          _MenuItem('Pengguna', Icons.manage_accounts_rounded, const Color(0xFF6A1B9A)),
          _MenuItem('Kalender', Icons.calendar_month_rounded, const Color(0xFF00695C)),
          _MenuItem('Pengaturan', Icons.settings_rounded, const Color(0xFF37474F)),
        ]),
      ],
    );
  }

  // --- Widget pendukung lainnya (statCard, menuGrid, dll) ---
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
  );

  Widget _statCard(String label, String value, IconData icon, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.plusJakartaSans(color: textColor.withOpacity(0.85), fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _menuGrid(List<_MenuItem> items) => GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    children: items.map(_buildMenuCard).toList(),
  );

  Widget _buildMenuCard(_MenuItem item) => Container(
    decoration: BoxDecoration(
      color: item.color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, color: item.textColor, size: 28),
        const SizedBox(height: 8),
        Text(item.label, style: GoogleFonts.plusJakartaSans(color: item.textColor, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ],
    ),
  );

  // Widget dummy untuk melengkapi switch case
  Widget _buildSekretarisDashboard() => _sectionTitle("Sekretaris Dashboard");
  Widget _buildKurikulumDashboard() => _sectionTitle("Kurikulum Dashboard");
  Widget _buildGuruDashboard() => _sectionTitle("Guru Dashboard");
  Widget _buildPiketDashboard() => _sectionTitle("Piket Dashboard");
  Widget _buildUbudiahDashboard() => _sectionTitle("Ubudiah Dashboard");
  Widget _buildKeamananDashboard() => _sectionTitle("Keamanan Dashboard");
  Widget _buildKebersihanDashboard() => _sectionTitle("Kebersihan Dashboard");
  Widget _buildPeralatanDashboard() => _sectionTitle("Peralatan Dashboard");
  Widget _buildKesehatanDashboard() => _sectionTitle("Kesehatan Dashboard");
  Widget _buildKesenianDashboard() => _sectionTitle("Kesenian Dashboard");
  Widget _buildRoisDashboard() => _sectionTitle("Rois Dashboard");
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  const _MenuItem(this.label, this.icon, this.color, {this.textColor = Colors.white});
}