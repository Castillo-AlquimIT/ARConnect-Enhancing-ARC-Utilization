import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testapp/App%20Menus/s_admin_panel.dart';
import 's_dashboard.dart';
import 's_register_page.dart';
import 'dart:convert';
import 'package:testapp/app_config.dart';

class SLoginPage extends StatefulWidget {
  const SLoginPage({super.key});

  @override
  State<SLoginPage> createState() => _SLoginPageState();
}

class _SLoginPageState extends State<SLoginPage> {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading   = false;
  bool _obscurePass = true;

  static const _purple       = Color(0xFF7C6EE6);
  static const _purpleLight  = Color(0xFFF3F0FF);
  static const _purpleMuted  = Color(0xFFA89CC8);
  static const _purpleBorder = Color(0xFFD5C9F5);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _purpleBorder, fontSize: 13),
        prefixIcon: Icon(icon, color: _purpleMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purpleBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purpleBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      );

  Future<void> _login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(AppConfig.instance.url("Spark", "login.php"));
    try {
      final response = await http.post(
        url,
        body: {"email": email, "password": password},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSnack(data["message"]);

        if (data["status"] == "success") {
          final user = data["user"];
          final role = user["role"] ?? "user";

          // Route based on role
          if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SAdminPage(
                  adminName: user["f_name"],
                  adminId: user["id"],
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SDashboardPage(userName: user["f_name"]),
              ),
            );
          }
        }
      } else {
        _showSnack("Server error. Please try again.");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack("Network error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purpleLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                const Text(
                  "SPARK",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _purple,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Solo Parenting Assistance & Resource Knowledge",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _purpleMuted),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13),
                  decoration:
                      _fieldDecor("Email address", Icons.email_outlined),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: passwordController,
                  obscureText: _obscurePass,
                  style: const TextStyle(fontSize: 13),
                  decoration: _fieldDecor(
                    "Password",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _purpleMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      disabledBackgroundColor:
                          _purple.withValues(alpha: 0.55),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text("Don't have an account?",
                    style: TextStyle(fontSize: 11, color: _purpleMuted)),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: _purple, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SRegisterPage()),
                            ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}