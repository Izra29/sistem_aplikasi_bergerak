import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'auth_service.dart';
import 'main.dart'; // Import main.dart untuk akses routeByRole

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Fungsi ini dipanggil setelah login sukses
  void _handleLoginSuccess(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => routeByRole(role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleLoginSuccess('admin'), // Contoh tes
          child: const Text("Masuk sebagai Admin"),
        ),
      ),
    );
  }
}