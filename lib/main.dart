// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/login_screen.dart';
import 'screens/orangtua_screen.dart';
import 'screens/pengurus_screen.dart';
import 'screens/admin_keuangan_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
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
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0f5132)),
        scaffoldBackgroundColor: const Color(0xFFf4f7f6),
      ),
      home: const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), _route);
  }

  Future<void> _route() async {
    if (!mounted) return;
    final session = await AuthService.getSession();
    final role    = session['role'];
    Widget next;
    switch (role) {
      case 'orangtua': next = const OrangtuaScreen(); break;
      case 'pengurus':  next = const PengurusScreen();       break;
      case 'admin':
      case 'superadmin':
      case 'bendahara':  next = const AdminKeuanganScreen(); break;
      default:         next = const LoginScreen();
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0a3622), Color(0xFF146c43)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110, height: 110,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.mosque_rounded, size: 70, color: Color(0xFF0f5132)),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text('NURUL IMAN',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 26, letterSpacing: 3,
                  )).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 8),

              Text('Sistem Informasi Akademik & Keuangan',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.7), fontSize: 13,
                  )).animate().fadeIn(delay: 450.ms, duration: 500.ms),

              const SizedBox(height: 40),

              const SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2.5),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
