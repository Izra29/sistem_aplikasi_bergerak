class AppConstants {
  // Sesuaikan: file PHP Anda langsung di public_html/ tanpa subfolder
  static const String baseUrl = 'https://niapps.id';

  static const String loginUrl         = '$baseUrl/api/login.php';
  static const String adminKeuanganUrl = '$baseUrl/api/admin_keuangan.php';
  static const String orangtuaUrl      = '$baseUrl/api/orangtua.php';
  static const String pengurusUrl      = '$baseUrl/api/pengurus.php';
}

class AppColors {
  static const int putraGreen      = 0xFF0f5132;
  static const int putraGreenLight = 0xFF146c43;
  static const int putraGlow       = 0xFF38ef7d;
  static const int putriPink       = 0xFFd63384;
  static const int putriPinkLight  = 0xFFe64980;
  static const int gold            = 0xFFffc107;
  static const int goldDark        = 0xFFe0a800;
  static const int pageBg          = 0xFFf4f7f6;
}