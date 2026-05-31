// lib/screens/admin_keuangan_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// ════════════════════════════════════════════════════════════
// SCREEN UTAMA: Dashboard (grid kotak-kotak menu)
// ════════════════════════════════════════════════════════════
class AdminKeuanganScreen extends StatefulWidget {
  const AdminKeuanganScreen({super.key});
  @override
  State<AdminKeuanganScreen> createState() => _AdminKeuanganScreenState();
}

class _AdminKeuanganScreenState extends State<AdminKeuanganScreen> {
  String _username = '';
  String _role     = 'bendahara';
  String _asrama   = 'putra';
  bool   _loading  = true;
  int    _pending  = 0;
  double _totalMasuk     = 0;
  double _totalTunggakan = 0;

  Color get _color      => _asrama == 'putra' ? const Color(0xFF0f5132) : const Color(0xFFd63384);
  Color get _colorLight => _asrama == 'putra' ? const Color(0xFF146c43) : const Color(0xFFe64980);
  LinearGradient get _grad => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [_color, _colorLight],
  );
  String get _namaAsrama => _asrama == 'putra' ? 'AN-NAHDLAH (PUTRA)' : 'AR-RUQOYAH (PUTRI)';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final s = await AuthService.getSession();
    setState(() {
      _username = s['username'] ?? 'Bendahara';
      _role     = s['role']     ?? 'bendahara';
      _asrama   = s['jenis_asrama'] ?? 'putra';
    });
    await _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse(AppConstants.adminKeuanganUrl),
        body: {'asrama': _asrama, 'tab': 'dashboard'},
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() {
          _pending        = (d['pending_count']                ?? 0) as int;
          _totalMasuk     = double.tryParse(d['summary']?['total_masuk']?.toString()     ?? '0') ?? 0;
          _totalTunggakan = double.tryParse(d['summary']?['total_tunggakan']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await AuthService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _goTo(String tab) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AdminDetailScreen(
        tab: tab, asrama: _asrama, username: _username, role: _role,
        color: _color, grad: _grad,
      ),
    )).then((_) => _fetchSummary());
  }

  String _rupiah(double v) {
    return 'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.pageBg),
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: _color))
              : RefreshIndicator(
            onRefresh: _fetchSummary, color: _color,
            child: _buildDashboard(),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(gradient: _grad),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 6),
                  Text(_namaAsrama, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                ]),
              ),
              Row(children: [
                if (_pending > 0)
                  GestureDetector(
                    onTap: () => _goTo('verifikasi'),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text('$_pending pending', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                      ]),
                    ),
                  ),
                IconButton(onPressed: _logout,
                    icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22)),
              ]),
            ]),
            const SizedBox(height: 10),
            CircleAvatar(radius: 30, backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 34)),
            const SizedBox(height: 8),
            Text(_username.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 2),
            Text('Panel Keuangan · ${_role.toUpperCase()}',
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.75), fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Kartu ringkasan
        Row(children: [
          _SummaryCard(label: 'Total Pemasukan',  value: _rupiah(_totalMasuk),     icon: Icons.arrow_downward_rounded, color: Colors.green),
          const SizedBox(width: 12),
          _SummaryCard(label: 'Total Tunggakan',  value: _rupiah(_totalTunggakan), icon: Icons.warning_amber_rounded,  color: Colors.red),
        ]).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 24),
        Text('Menu Utama',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF222222))),
        const SizedBox(height: 12),

        // Grid kotak menu
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _MenuBox(icon: Icons.verified_rounded,              label: 'Verifikasi\nTransfer',  color: Colors.green,    badge: _pending, delay: 0,   onTap: () => _goTo('verifikasi')),
            _MenuBox(icon: Icons.calendar_month_rounded,        label: 'Syahriah\n(SPP)',       color: _color,          delay: 80,  onTap: () => _goTo('syahriah')),
            _MenuBox(icon: Icons.warning_amber_rounded,         label: 'Tunggakan\nSantri',     color: Colors.red,      delay: 160, onTap: () => _goTo('tunggakan')),
            _MenuBox(icon: Icons.wallet_rounded,                label: 'Uang\nJajan',           color: Colors.teal,     delay: 240, onTap: () => _goTo('jajan')),
            _MenuBox(icon: Icons.local_laundry_service_rounded, label: 'Laundry\nSantri',       color: Colors.indigo,   delay: 320, onTap: () => _goTo('laundry')),
            _MenuBox(icon: Icons.history_rounded,               label: 'Riwayat\nTransaksi',   color: Colors.blueGrey, delay: 400, onTap: () => _goTo('riwayat')),
            _MenuBox(icon: Icons.settings_rounded,              label: 'Pengaturan\nTarif',     color: Colors.orange,   delay: 480, onTap: () => _goTo('pengaturan')),
          ],
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SCREEN DETAIL: Per Tab dengan Filter
// ════════════════════════════════════════════════════════════
class AdminDetailScreen extends StatefulWidget {
  final String tab, asrama, username, role;
  final Color color;
  final LinearGradient grad;
  const AdminDetailScreen({super.key, required this.tab, required this.asrama,
    required this.username, required this.role, required this.color, required this.grad});
  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  // ── Filter ───────────────────────────────────────────────
  String _kobongId   = '';
  String _namaKobong = '';
  String _kelas      = '';
  int    _bulan      = DateTime.now().month;
  int    _tahun      = DateTime.now().month >= 7 ? DateTime.now().year : DateTime.now().year - 1;

  bool get _adaFilter => _kobongId.isNotEmpty || _kelas.isNotEmpty;
  bool get _noFilter  => widget.tab == 'verifikasi' || widget.tab == 'pengaturan';
  // Riwayat butuh filter bulan tapi tidak butuh kobong/kelas
  bool get _riwayatTab => widget.tab == 'riwayat';

  // ── Data ─────────────────────────────────────────────────
  bool   _loading   = false;
  List   _dataList  = [];
  List   _kobongList = [];
  Map    _pengaturan = {};
  double _totalMasukGlobal     = 0;
  double _totalTunggakanGlobal = 0;
  double _totalTunggakanFilter = 0;

  // Daftar kelas
  List<String> get _kelasSmp {
    final h = widget.asrama == 'putra' ? ['A','B','C','D'] : ['E','F','G','H'];
    return [for (final t in ['7','8','9']) for (final x in h) '$t$x'];
  }
  static const _kelasMa = ['10 Baru','10 Lama','11 Gabung','12 Gabung'];

  // Nama bulan
  static const _namaBulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];

  String get _pageTitle {
    switch (widget.tab) {
      case 'verifikasi': return 'Verifikasi Transfer';
      case 'syahriah':   return 'Syahriah (SPP)';
      case 'tunggakan':  return 'Tunggakan Santri';
      case 'jajan':      return 'Uang Jajan';
      case 'laundry':    return 'Laundry';
      case 'riwayat':    return 'Riwayat Transaksi';
      case 'pengaturan': return 'Pengaturan Tarif';
      default:           return '';
    }
  }

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse(AppConstants.adminKeuanganUrl),
        body: {
          'asrama':    widget.asrama,
          'tab':       widget.tab,
          'kobong_id': _kobongId,
          'kelas':     _kelas,
          'bulan':     _bulan.toString(),
          'tahun':     _tahun.toString(),
        },
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() {
          _kobongList              = List.from(d['kobong_list']            ?? []);
          _pengaturan              = Map.from(d['pengaturan']              ?? {});
          _totalMasukGlobal        = double.tryParse(d['total_masuk_global']?.toString()     ?? '0') ?? 0;
          _totalTunggakanGlobal    = double.tryParse(d['total_tunggakan_global']?.toString() ?? '0') ?? 0;
          _totalTunggakanFilter    = double.tryParse(d['total_tunggakan_filter']?.toString() ?? '0') ?? 0;

          switch (widget.tab) {
            case 'verifikasi': _dataList = List.from(d['verifikasi'] ?? []); break;
            case 'syahriah':   _dataList = List.from(d['syahriah']   ?? []); break;
            case 'tunggakan':  _dataList = List.from(d['tunggakan']  ?? []); break;
            case 'jajan':      _dataList = List.from(d['jajan']      ?? []); break;
            case 'laundry':    _dataList = List.from(d['laundry']    ?? []); break;
            case 'riwayat':    _dataList = List.from(d['riwayat']    ?? []); break;
          }
        });
      }
    } catch (e) { debugPrint('Fetch error: $e'); }
    setState(() => _loading = false);
  }

  // ── Aksi ─────────────────────────────────────────────────
  Future<void> _aksiVerifikasi(String id, String aksi) async {
    final ok = await _confirm(
      aksi == 'terima' ? 'Terima Pembayaran?' : 'Tolak Pembayaran?',
      aksi == 'terima' ? 'Transaksi akan diproses ke sistem.' : 'Pembayaran ini akan ditolak.',
      aksi == 'terima' ? Colors.green : Colors.red,
    );
    if (!ok) return;
    await http.post(Uri.parse(AppConstants.adminKeuanganUrl), body: {
      'aksi': 'verifikasi', 'id': id, 'aksi_verifikasi': aksi, 'asrama': widget.asrama,
    });
    _snack(aksi == 'terima' ? '✅ Pembayaran diterima!' : '❌ Pembayaran ditolak.',
        aksi == 'terima' ? Colors.green : Colors.red);
    _fetch();
  }

  Future<void> _hapus(String id) async {
    if (!await _confirm('Hapus Transaksi?', 'Data akan dihapus permanen.', Colors.red)) return;
    await http.post(Uri.parse(AppConstants.adminKeuanganUrl), body: {
      'aksi': 'hapus_transaksi', 'id': id, 'asrama': widget.asrama,
    });
    _snack('🗑️ Transaksi dihapus.', Colors.orange);
    _fetch();
  }

  Future<bool> _confirm(String title, String body, Color color) async =>
      await showDialog<bool>(context: context, builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:   Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(body,  style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.grey))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Ya', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      )) ?? false;

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: color, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Future<void> _showTransaksiDialog(String sid, String nama, String kat, String jenis) async {
    final ctrlNom = TextEditingController();
    final ctrlKet = TextEditingController();
    final judul = kat == 'tabungan' && jenis == 'masuk' ? 'Isi Saldo Jajan'
        : kat == 'tabungan' && jenis == 'keluar' ? 'Kasih Uang Jajan'
        : kat == 'syahriah' ? 'Bayar Syahriah' : 'Bayar Laundry';

    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(judul, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: widget.color)),
            Text(nama,  style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(controller: ctrlNom, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nominal (Rp)',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: ctrlKet,
                decoration: InputDecoration(labelText: 'Keterangan (opsional)',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if (ctrlNom.text.isEmpty) return;
                      Navigator.pop(context);
                      await http.post(Uri.parse(AppConstants.adminKeuanganUrl), body: {
                        'aksi': 'transaksi', 'santri_id': sid, 'kategori': kat,
                        'jenis': jenis, 'nominal': ctrlNom.text,
                        'keterangan': ctrlKet.text, 'asrama': widget.asrama,
                      });
                      _snack('✅ Transaksi berhasil!', Colors.green);
                      _fetch();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: Text('SIMPAN TRANSAKSI',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)))),
          ]),
        ),
      ),
    );
  }

  String _rupiah(dynamic v) {
    final n = double.tryParse(v?.toString() ?? '0') ?? 0;
    return 'Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.pageBg),
      appBar: AppBar(
        backgroundColor: widget.color, foregroundColor: Colors.white, elevation: 0,
        title: Text(_pageTitle,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch, tooltip: 'Refresh'),
        ],
      ),
      body: Column(children: [
        // Panel filter
        if (!_noFilter) _buildFilterPanel(),
        // Konten
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: widget.color))
              : RefreshIndicator(
            onRefresh: _fetch, color: widget.color,
            child: _buildContent(),
          ),
        ),
      ]),
    );
  }

  // ── Panel Filter ─────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Baris 1: Kobong & Kelas (tidak tampil di tab riwayat)
        if (!_riwayatTab) ...[
          Row(children: [
            // Kobong
            Expanded(child: _dd<String>(
              value: _kobongId.isEmpty ? '' : _kobongId,
              hint:  'Semua Kobong',
              items: [
                _ddItem('', 'Semua Kobong', italic: true),
                ..._kobongList.map((k) => _ddItem(k['id'].toString(), k['nama_kobong'] ?? '')),
              ],
              onChanged: (v) {
                setState(() {
                  _kobongId   = v ?? '';
                  _namaKobong = _kobongList.firstWhere(
                          (k) => k['id'].toString() == v, orElse: () => {})['nama_kobong'] ?? '';
                  _kelas = ''; // reset kelas
                });
                _fetch();
              },
            )),
            const SizedBox(width: 8),
            // Kelas
            Expanded(child: _dd<String>(
              value: _kelas.isEmpty ? '' : _kelas,
              hint:  'Semua Kelas',
              items: [
                _ddItem('', 'Semua Kelas', italic: true),
                ..._kelasSmp.map((k) => _ddItem(k, 'SMP - $k')),
                ..._kelasMa.map((k) => _ddItem(k, 'MA  - $k')),
              ],
              onChanged: (v) {
                setState(() { _kelas = v ?? ''; _kobongId = ''; _namaKobong = ''; });
                _fetch();
              },
            )),
          ]),
          const SizedBox(height: 8),
        ],

        // Baris 2: Bulan & Tahun & Reset
        Row(children: [
          // Bulan
          Expanded(child: _dd<int>(
            value: _bulan,
            hint:  'Bulan',
            items: List.generate(12, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_namaBulan[i + 1], style: GoogleFonts.plusJakartaSans(fontSize: 13)))),
            onChanged: (v) { setState(() => _bulan = v ?? _bulan); _fetch(); },
          )),
          const SizedBox(width: 8),
          // Tahun Ajaran
          Expanded(child: _dd<int>(
            value: _tahun,
            hint:  'Tahun Ajaran',
            items: List.generate(11, (i) => DropdownMenuItem(
                value: 2020 + i,
                child: Text('TA ${2020 + i}/${2021 + i}', style: GoogleFonts.plusJakartaSans(fontSize: 13)))),
            onChanged: (v) { setState(() => _tahun = v ?? _tahun); _fetch(); },
          )),
          const SizedBox(width: 8),
          // Tombol reset
          GestureDetector(
              onTap: () {
                setState(() { _kobongId = ''; _kelas = ''; _namaKobong = '';
                _bulan = DateTime.now().month;
                _tahun = DateTime.now().month >= 7 ? DateTime.now().year : DateTime.now().year - 1; });
                _fetch();
              },
              child: Container(height: 42, width: 44,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20))),
        ]),

        // Badge filter aktif
        if (_adaFilter || !_riwayatTab)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Icon(Icons.filter_alt_rounded, size: 13, color: widget.color),
              const SizedBox(width: 4),
              Expanded(child: Text(
                _adaFilter
                    ? 'Filter: ${_namaKobong.isNotEmpty ? _namaKobong : "Kelas $_kelas"} · ${_namaBulan[_bulan]} $_tahun'
                    : 'Bulan: ${_namaBulan[_bulan]} · TA $_tahun/${_tahun + 1}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: widget.color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              )),
            ]),
          ),
      ]),
    );
  }

  // Helper dropdown
  Widget _dd<T>({
    required T value, required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) => Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.25))),
    child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, isExpanded: true,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black87),
          items: items, onChanged: onChanged,
        )),
  );

  DropdownMenuItem<String> _ddItem(String value, String label, {bool italic = false}) =>
      DropdownMenuItem(value: value, child: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: italic ? Colors.grey : Colors.black87,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal)));

  // ════════════════════════════════════════════════════════
  // CONTENT ROUTER
  // ════════════════════════════════════════════════════════
  Widget _buildContent() {
    // Tab yang butuh kobong/kelas → tampilkan prompt dulu
    final butuhFilter = !_noFilter && !_riwayatTab;
    if (butuhFilter && !_adaFilter) return _filterPrompt();

    switch (widget.tab) {
      case 'verifikasi': return _listVerifikasi();
      case 'syahriah':   return _listSyahriah();
      case 'tunggakan':  return _listTunggakan();
      case 'jajan':      return _listJajan();
      case 'laundry':    return _listLaundry();
      case 'riwayat':    return _listRiwayat();
      case 'pengaturan': return _pagePengaturan();
      default:           return const SizedBox();
    }
  }

  Widget _filterPrompt() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.filter_alt_outlined, size: 72, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('Pilih Kobong atau Kelas dulu',
          style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Gunakan filter di atas', style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 13)),
    ]),
  );

  Widget _empty(IconData icon, String msg, Color color) => Center(
    child: Padding(padding: const EdgeInsets.all(48),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 60, color: color.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 14, height: 1.6)),
        ])),
  );

  // ── Mini stat card ───────────────────────────────────────
  Widget _miniStats() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      _statChip('Masuk Global',    _rupiah(_totalMasukGlobal),     Colors.green),
      const SizedBox(width: 8),
      _statChip('Tunggakan Global',_rupiah(_totalTunggakanGlobal), Colors.red),
      if (_adaFilter) ...[
        const SizedBox(width: 8),
        _statChip('Tunggakan Filter', _rupiah(_totalTunggakanFilter), Colors.orange),
      ],
    ]),
  );

  Widget _statChip(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        Text(label,  style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 9, height: 1.4)),
      ]),
    ),
  );

  // ── List: Verifikasi ─────────────────────────────────────
  Widget _listVerifikasi() {
    if (_dataList.isEmpty) return _empty(Icons.check_circle_rounded, 'Semua transfer sudah diverifikasi!', Colors.green);
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: _dataList.length,
      itemBuilder: (_, i) => _VerifikasiCard(
        item: _dataList[i], rupiah: _rupiah, color: widget.color,
        onTerima: () => _aksiVerifikasi(_dataList[i]['id'].toString(), 'terima'),
        onTolak:  () => _aksiVerifikasi(_dataList[i]['id'].toString(), 'tolak'),
      ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1, end: 0),
    );
  }

  // ── List: Syahriah ───────────────────────────────────────
  Widget _listSyahriah() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _miniStats(),
      if (_dataList.isEmpty)
        _empty(Icons.people_outline_rounded, 'Tidak ada data santri\npada filter ini.', widget.color)
      else
        ..._dataList.asMap().entries.map((e) => _SyahriahCard(
          item: e.value, rupiah: _rupiah, color: widget.color,
          onBayar: () => _showTransaksiDialog(
              e.value['id'].toString(), e.value['nama_santri'] ?? '', 'syahriah', 'masuk'),
        ).animate().fadeIn(delay: (e.key * 40).ms)),
    ],
  );

  // ── List: Tunggakan ──────────────────────────────────────
  Widget _listTunggakan() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _miniStats(),
      if (_dataList.isEmpty)
        _empty(Icons.check_circle_outline_rounded, 'Semua santri di filter ini sudah lunas!', Colors.green)
      else
        ..._dataList.asMap().entries.map((e) => _TunggakanCard(
          item: e.value, rupiah: _rupiah,
        ).animate().fadeIn(delay: (e.key * 40).ms)),
    ],
  );

  // ── List: Jajan ──────────────────────────────────────────
  Widget _listJajan() {
    if (_dataList.isEmpty) return _empty(Icons.wallet_rounded, 'Tidak ada data santri\npada filter ini.', widget.color);
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: _dataList.length,
      itemBuilder: (_, i) => _JajanCard(
        item: _dataList[i], rupiah: _rupiah, color: widget.color,
        onTambah: () => _showTransaksiDialog(_dataList[i]['id'].toString(), _dataList[i]['nama_santri'] ?? '', 'tabungan', 'masuk'),
        onKasih:  () => _showTransaksiDialog(_dataList[i]['id'].toString(), _dataList[i]['nama_santri'] ?? '', 'tabungan', 'keluar'),
      ).animate().fadeIn(delay: (i * 40).ms),
    );
  }

  // ── List: Laundry ────────────────────────────────────────
  Widget _listLaundry() {
    if (_dataList.isEmpty) return _empty(Icons.local_laundry_service_rounded, 'Tidak ada data santri\npada filter ini.', widget.color);
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: _dataList.length,
      itemBuilder: (_, i) => _LaundryCard(
        item: _dataList[i], rupiah: _rupiah, color: widget.color,
        onBayar: () => _showTransaksiDialog(_dataList[i]['id'].toString(), _dataList[i]['nama_santri'] ?? '', 'laundry', 'masuk'),
      ).animate().fadeIn(delay: (i * 40).ms),
    );
  }

  // ── List: Riwayat ────────────────────────────────────────
  Widget _listRiwayat() {
    if (_dataList.isEmpty) return _empty(Icons.history_rounded,
        'Tidak ada transaksi\ndi ${_namaBulan[_bulan]} $_tahun.', widget.color);
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: _dataList.length,
      itemBuilder: (_, i) => _RiwayatCard(
        item: _dataList[i], rupiah: _rupiah, color: widget.color,
        onHapus: () => _hapus(_dataList[i]['id'].toString()),
      ).animate().fadeIn(delay: (i * 30).ms),
    );
  }

  // ── Pengaturan ───────────────────────────────────────────
  Widget _pagePengaturan() {
    final ctrlS = TextEditingController(text: _pengaturan['biaya_syahriah']?.toString() ?? '150000');
    final ctrlL = TextEditingController(text: _pengaturan['biaya_laundry']?.toString()  ?? '50000');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tarif Aktif',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: widget.color)),
            const SizedBox(height: 16),
            TextField(controller: ctrlS, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Biaya Syahriah (Rp)',
                    prefixIcon: const Icon(Icons.calendar_month_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: ctrlL, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Biaya Laundry (Rp)',
                    prefixIcon: const Icon(Icons.local_laundry_service_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      await http.post(Uri.parse(AppConstants.adminKeuanganUrl), body: {
                        'aksi': 'simpan_pengaturan', 'biaya_syahriah': ctrlS.text,
                        'biaya_laundry': ctrlL.text, 'asrama': widget.asrama,
                      });
                      _snack('✅ Tarif disimpan!', Colors.green);
                    },
                    icon:  const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text('SIMPAN TARIF', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          ]),
        ),
        const SizedBox(height: 16),
        _UbahSandiCard(color: widget.color, username: widget.username, asrama: widget.asrama,
            onSnack: (m, c) => _snack(m, c)),
      ],
    );
  }

}

// ════════════════════════════════════════════════════════════
// WIDGET CARDS (Shared)
// ════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 11, height: 1.4)),
      ]),
    ),
  );
}

class _MenuBox extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final int badge, delay; final VoidCallback onTap;
  const _MenuBox({required this.icon, required this.label, required this.color,
    required this.onTap, required this.delay, this.badge = 0});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Stack(children: [
        Positioned(right: -14, bottom: -14,
            child: Container(width: 70, height: 70,
                decoration: BoxDecoration(color: color.withOpacity(0.07), shape: BoxShape.circle))),
        Positioned(right: 6, bottom: 6,
            child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.07), shape: BoxShape.circle))),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 46, height: 46,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 13.5, color: const Color(0xFF1a1a2e), height: 1.3)),
          ]),
        ),
        if (badge > 0)
          Positioned(top: 12, right: 12,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text('$badge', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)))),
      ]),
    ),
  ).animate().fadeIn(delay: delay.ms, duration: 400.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
}

class _VerifikasiCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah; final Color color;
  final VoidCallback onTerima, onTolak;
  const _VerifikasiCard({required this.item, required this.rupiah, required this.color, required this.onTerima, required this.onTolak});
  Widget _r(String l, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ]));
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFF198754),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
          Text('Kls: ${item['kelas'] ?? '-'} · ${item['tanggal'] ?? '-'}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('PENDING', style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 11))),
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _r('Nominal',    rupiah(item['nominal'] ?? 0), bold: true),
            _r('Kategori',   (item['kategori'] ?? '').toString().toUpperCase()),
            _r('Keterangan', item['keterangan'] ?? '-'),
          ])),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: onTolak,
            icon: const Icon(Icons.close_rounded, color: Colors.red, size: 16),
            label: Text('TOLAK', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton.icon(onPressed: onTerima,
            icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            label: Text('TERIMA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
      ]),
    ]),
  );
}

class _SyahriahCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah; final Color color; final VoidCallback onBayar;
  const _SyahriahCard({required this.item, required this.rupiah, required this.color, required this.onBayar});
  static const _bln = ['Jul','Ags','Sep','Okt','Nov','Des','Jan','Feb','Mar','Apr','Mei','Jun'];
  @override
  Widget build(BuildContext context) {
    final isLunas   = (item['status'] ?? '') == 'lunas';
    final bulanData = (item['bulan_data'] as List?) ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isLunas ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Kelas ${item['kelas'] ?? '-'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
            if (!isLunas) Text('Tunggakan: ${rupiah(item['tunggakan'] ?? 0)}',
                style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
          ])),
          if (!isLunas)
            ElevatedButton(onPressed: onBayar,
                style: ElevatedButton.styleFrom(backgroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Bayar', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))
          else const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
        ]),
        if (bulanData.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 4, runSpacing: 4, children: _bln.asMap().entries.map((e) {
            final ok = e.key < bulanData.length ? (bulanData[e.key] == 1) : false;
            return Container(width: 34, height: 26,
                decoration: BoxDecoration(
                    color: ok ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ok ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.2))),
                child: Center(child: Text(e.value,
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700,
                        color: ok ? Colors.green[700] : Colors.red[300]))));
          }).toList()),
        ],
      ]),
    );
  }
}

class _TunggakanCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah;
  const _TunggakanCard({required this.item, required this.rupiah});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.2))),
    child: Row(children: [
      const CircleAvatar(radius: 20, backgroundColor: Color(0xFFFFEBEE),
          child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        Text('Kelas ${item['kelas'] ?? '-'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        if ((item['rincian'] ?? '').toString().isNotEmpty)
          Text(item['rincian'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.red[400])),
      ])),
      Text(rupiah(item['total_tunggakan'] ?? 0),
          style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );
}

class _JajanCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah; final Color color;
  final VoidCallback onTambah, onKasih;
  const _JajanCard({required this.item, required this.rupiah, required this.color, required this.onTambah, required this.onKasih});
  @override
  Widget build(BuildContext context) {
    final saldo = double.tryParse(item['saldo']?.toString() ?? '0') ?? 0;
    final isLow = saldo < 20000;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          border: Border.all(color: isLow ? Colors.orange.withOpacity(0.4) : Colors.grey.withOpacity(0.1))),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.1),
              child: Icon(Icons.person_rounded, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Kelas ${item['kelas'] ?? '-'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rupiah(saldo), style: GoogleFonts.plusJakartaSans(
                color: isLow ? Colors.orange : Colors.green, fontWeight: FontWeight.w800, fontSize: 15)),
            if (isLow) Text('Rendah', style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: onKasih,
              icon: Icon(Icons.arrow_upward_rounded, color: color, size: 14),
              label: Text('Kasih Jajan', style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: color.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: onTambah,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 14),
              label: Text('Isi Saldo', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8)))),
        ]),
      ]),
    );
  }
}

class _LaundryCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah; final Color color; final VoidCallback onBayar;
  const _LaundryCard({required this.item, required this.rupiah, required this.color, required this.onBayar});
  @override
  Widget build(BuildContext context) {
    final isLunas = (item['status'] ?? '') == 'lunas';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isLunas ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.15))),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.08),
            child: Icon(Icons.local_laundry_service_rounded, color: color, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
          Text('Kelas ${item['kelas'] ?? '-'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        ])),
        if (!isLunas)
          ElevatedButton(onPressed: onBayar,
              style: ElevatedButton.styleFrom(backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Bayar', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))
        else const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
      ]),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final Map item; final String Function(dynamic) rupiah; final Color color; final VoidCallback onHapus;
  const _RiwayatCard({required this.item, required this.rupiah, required this.color, required this.onHapus});
  @override
  Widget build(BuildContext context) {
    final isMasuk = (item['jenis'] ?? '') == 'masuk';
    final kat     = (item['kategori'] ?? '').toString();
    final katIcon = kat == 'tabungan' ? Icons.wallet_rounded
        : kat == 'syahriah' ? Icons.calendar_month_rounded
        : kat == 'laundry'  ? Icons.local_laundry_service_rounded : Icons.swap_horiz_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(children: [
        CircleAvatar(radius: 18,
            backgroundColor: isMasuk ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            child: Icon(katIcon, color: isMasuk ? Colors.green : Colors.red, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['nama_santri'] ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
          Text('${kat.toUpperCase()} · ${item['tanggal'] ?? '-'}',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
          if ((item['keterangan'] ?? '').toString().isNotEmpty)
            Text(item['keterangan'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[600])),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${isMasuk ? '+' : '-'}${rupiah(item['nominal'] ?? 0)}',
              style: GoogleFonts.plusJakartaSans(
                  color: isMasuk ? Colors.green : Colors.red, fontWeight: FontWeight.w800, fontSize: 12)),
          GestureDetector(onTap: onHapus,
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18)),
        ]),
      ]),
    );
  }
}

class _UbahSandiCard extends StatefulWidget {
  final Color color; final String username, asrama;
  final void Function(String, Color) onSnack;
  const _UbahSandiCard({required this.color, required this.username, required this.asrama, required this.onSnack});
  @override State<_UbahSandiCard> createState() => _UbahSandiState();
}
class _UbahSandiState extends State<_UbahSandiCard> {
  final _ctrl = TextEditingController(); bool _show = false;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ubah Kata Sandi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: widget.color)),
      const SizedBox(height: 14),
      TextField(controller: _ctrl, obscureText: !_show,
          decoration: InputDecoration(
              labelText: 'Kata Sandi Baru', prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _show = !_show)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
              onPressed: () async {
                if (_ctrl.text.isEmpty) return;
                await http.post(Uri.parse(AppConstants.adminKeuanganUrl), body: {
                  'aksi': 'ubah_sandi', 'new_pass': _ctrl.text,
                  'username': widget.username, 'asrama': widget.asrama,
                });
                widget.onSnack('✅ Kata sandi diperbarui!', Colors.green);
              },
              icon: const Icon(Icons.key_rounded, color: Colors.white),
              label: Text('SIMPAN SANDI BARU',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: widget.color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
    ]),
  );
}
