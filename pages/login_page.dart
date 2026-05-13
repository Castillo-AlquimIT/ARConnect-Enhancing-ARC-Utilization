import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testapp/app_config.dart';
import 'dart:convert';
import 'register_page.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final numIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  
  Null get navigator => null;

  Future<void> login() async {
    setState(() => _isLoading = true);

    var url = Uri.parse(AppConfig.instance.url("ARConnect", "login.php"));
    try {
      var response = await http.post(url, body: {
        "num_id": numIdController.text,
        "password": passwordController.text,
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );

        if (data["status"] == "success") {
          final user = data["user"];

          // Build full display name from new fields
          final firstName = user["name"]   ?? '';
          final lastName  = user["last"]   ?? '';
          final suffix    = user["suffix"] ?? '';
          final fullName  = [firstName, lastName, suffix]
              .where((s) => s.toString().isNotEmpty)
              .join(' ');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                userId:   user["id"],
                numId:    user["num_id"],
                userName: fullName,
                role:     user["role"] ?? 'student',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ARConnect title
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "ARC",
                        style: TextStyle(color: Color(0xFF8B1C14)),
                      ),
                      TextSpan(
                        text: "onnect",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Student Number / Faculty ID
                TextField(
                  controller: numIdController,
                  decoration: const InputDecoration(
                    labelText: "Student Number / Faculty ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1C14),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      disabledBackgroundColor:
                          const Color(0xFF8B1C14).withValues(alpha: 0.6),
                    ),
                    onPressed: _isLoading ? null : login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Don't have an account?"),
                const SizedBox(height: 10),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const RegisterPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // OR divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Microsoft 365 login
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            //navigator.push(
                              //context,
                             // PageRouteBuilder(
                               // pageBuilder: (_, __, ___) =>
                                 //   const MicrosoftLoginPage(),
                              //  transitionDuration: Duration.zero,
                              //  reverseTransitionDuration: Duration.zero,
                            //  ),
                           // );
                          },
                    child: const Text(
                      "Login via LPU Microsoft 365",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}