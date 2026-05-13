import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:testapp/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final numIdController    = TextEditingController();
  final firstNameController  = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController   = TextEditingController();
  final suffixController     = TextEditingController();
  final passwordController   = TextEditingController();

  bool _isLoading = false;

  Future<void> register() async {

    // Client-side required field check (middle & suffix are optional)
    if (numIdController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    var url = Uri.parse(AppConfig.instance.url("ARConnect", "register.php"));

    try {

      if (kDebugMode) debugPrint("Sending registration request...");

      var response = await http.post(
        url,
        body: {
          "num_id":  numIdController.text.trim(),
          "name":    firstNameController.text.trim(),    // PHP expects 'name' for u_first
          "middle":  middleNameController.text.trim(),   // optional
          "last":    lastNameController.text.trim(),
          "suffix":  suffixController.text.trim(),       // optional
          "password": passwordController.text,
        },
      );

      if (!mounted) return;

      if (kDebugMode) debugPrint(response.body);

      if (response.statusCode == 200) {

        var data = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );

        if (data["status"] == "success") {
          numIdController.clear();
          firstNameController.clear();
          middleNameController.clear();
          lastNameController.clear();
          suffixController.clear();
          passwordController.clear();

          Navigator.pop(context);
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
        );
      }

    } catch (e) {

      if (kDebugMode) debugPrint("Network error: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    numIdController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    suffixController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Register"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // Student Number / Faculty ID *
            TextField(
              controller: numIdController,
              decoration: const InputDecoration(
                labelText: "Student Number / Faculty ID *",
                hintText: "2023-2-0001",
              ),
            ),

            const SizedBox(height: 10),

            // First Name *
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name *",
              ),
            ),

            const SizedBox(height: 10),

            // Middle Name (optional)
            TextField(
              controller: middleNameController,
              decoration: const InputDecoration(
                labelText: "Middle Name (If applicable)",
              ),
            ),

            const SizedBox(height: 10),

            // Last Name *
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name *",
              ),
            ),

            const SizedBox(height: 10),

            // Suffix (optional)
            TextField(
              controller: suffixController,
              decoration: const InputDecoration(
                labelText: "Suffix (Optional)",
                hintText: "Jr., Sr., III",
              ),
            ),

            const SizedBox(height: 10),

            // Password *
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password *",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}