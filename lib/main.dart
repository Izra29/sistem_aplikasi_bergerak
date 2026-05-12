import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NurulImanApp());
}

class NurulImanApp extends StatelessWidget {
  const NurulImanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurul Iman',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146c43)),
        useMaterial3: true,
      ),
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (role.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => routeByRole(role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0b3d24),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFffc107)),
      ),
    );
  }
}

/// Helper global untuk routing berdasarkan role
Widget routeByRole(String role) {
  switch (role) {
    case 'admin':
    case 'superadmin':
    case 'bendahara':
      return const DashboardScreen(role: 'admin');
    case 'sekretaris':
      return const DashboardScreen(role: 'sekretaris');
    case 'kurikulum':
      return const DashboardScreen(role: 'kurikulum');
    case 'guru':
    case 'walikelas':
      return const DashboardScreen(role: 'guru');
    case 'piket':
      return const DashboardScreen(role: 'piket');
    case 'ubudiah':
      return const DashboardScreen(role: 'ubudiah');
    case 'keamanan':
      return const DashboardScreen(role: 'keamanan');
    case 'kebersihan':
      return const DashboardScreen(role: 'kebersihan');
    case 'peralatan':
      return const DashboardScreen(role: 'peralatan');
    case 'kesehatan':
      return const DashboardScreen(role: 'kesehatan');
    case 'kesenian':
      return const DashboardScreen(role: 'kesenian');
    case 'rois':
      return const DashboardScreen(role: 'rois');
    default:
      AuthService.logout();
      return const LoginScreen();
  }
}