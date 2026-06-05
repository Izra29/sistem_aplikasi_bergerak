// lib/screens/orangtua_screen.dart
// Halaman Wali Santri — placeholder siap diisi konten API
// Tab: Jajan | SPP | Izin | Hafalan | Nilai | Biodata

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class OrangtuaScreen extends StatefulWidget {
  const OrangtuaScreen({super.key});
  @override
  State<OrangtuaScreen> createState() => _OrangtuaScreenState();
}

class _OrangtuaScreenState extends State<OrangtuaScreen> {
  int    _tab      = 0;
  String _username = '';
  String _asrama   = 'putra';

  Color get _color => _asrama == 'putra' ? const Color(0xFF0f5132) : const Color(0xFFd63384);
  LinearGradient get _grad => _asrama == 'putra'
      ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0f5132), Color(0xFF146c43)])
      : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFd63384), Color(0xFFe64980)]);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final s = await AuthService.getSession();
    setState(() { _username = s['username'] ?? 'Wali'; _asrama = s['jenis_asrama'] ?? 'putra'; });
  }

  Future<void> _logout() async {
    await AuthService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  static const _tabs = [
    {'icon': Icons.wallet_rounded,          'label': 'Jajan'},
    {'icon': Icons.calendar_month_rounded,  'label': 'SPP'},
    {'icon': Icons.turn_right_rounded,      'label': 'Izin'},
    {'icon': Icons.book_rounded,            'label': 'Hafalan'},
    {'icon': Icons.bar_chart_rounded,       'label': 'Nilai'},
    {'icon': Icons.badge_rounded,           'label': 'Biodata'},
  ];

  static const _titles = ['Saldo Uang Jajan','Status SPP','Perizinan','Hafalan','Nilai','Biodata'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.pageBg),
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:        _tab,
        onTap:               (i) => setState(() => _tab = i),
        type:                BottomNavigationBarType.fixed,
        selectedItemColor:   _color,
        unselectedItemColor: const Color(0xFFa0aec0),
        selectedFontSize:    11,
        unselectedFontSize:  11,
        selectedLabelStyle:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        backgroundColor:     Colors.white,
        elevation:           12,
        items: _tabs.map((t) => BottomNavigationBarItem(
          icon:  Icon(t['icon'] as IconData),
          label: t['label'] as String,
        )).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: _grad),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22),
                tooltip: 'Keluar',
              ),
            ]),
            const CircleAvatar(radius: 36, backgroundColor: Colors.white24,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 40)),
            const SizedBox(height: 10),
            Text(_username.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Portal Wali Santri',
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.75), fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _PlaceholderCard(
          icon:  _tabs[_tab]['icon'] as IconData,
          title: _titles[_tab],
          color: _color,
          desc:  'Konten tab "${_titles[_tab]}" akan diisi di sini.\nEndpoint: ${AppConstants.orangtuaUrl}',
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 16),
        _InfoCard(
          icon:  Icons.info_outline_rounded,
          color: Colors.blue,
          title: 'Untuk Developer',
          body:  'Tab ini terhubung ke tab="${_titles[_tab].toLowerCase()}" di orangtua.php.\nHubungkan API lalu ganti widget placeholder ini.',
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
      ]),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────
class _PlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _PlaceholderCard({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Column(children: [
      Icon(icon, size: 58, color: color.withOpacity(0.6)),
      const SizedBox(height: 16),
      Text(title, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 8),
      Text(desc, textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF888888), fontSize: 13, height: 1.6)),
    ]),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final Color color;
  const _InfoCard({required this.icon, required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF555555))),
      ])),
    ]),
  );
}
