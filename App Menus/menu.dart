import 'package:flutter/material.dart';
import 'package:testapp/App%20Menus/s_login_page.dart';
import 'package:testapp/app_config.dart';
import 'package:testapp/pages/login_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  void _openSettings() {
    final controller =
        TextEditingController(text: AppConfig.instance.baseUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Server Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Paste your Ngrok URL or local IP below.',
              style: TextStyle(fontSize: 13, color: Colors.white38),
            ),
            const SizedBox(height: 20),

            // URL examples
            const _UrlExample(label: 'Emulator', url: 'http://10.0.2.2'),
            const _UrlExample(label: 'Local network', url: 'http://192.168.1.x'),
            const _UrlExample(label: 'Ngrok', url: 'https://xxxx-xx-xx.ngrok-free.app'),

            const SizedBox(height: 20),

            // Input
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Base URL',
                labelStyle: const TextStyle(color: Colors.white38),
                hintText: 'https://your-ngrok-url.ngrok-free.app',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final raw = controller.text.trim();
                  // Strip trailing slash
                  AppConfig.instance.baseUrl =
                      raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Base URL updated: ${AppConfig.instance.baseUrl}'),
                      backgroundColor: const Color(0xFF1A1A1A),
                    ),
                  );
                  setState(() {}); // refresh displayed URL
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dev\nLauncher',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an app to preview',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white38,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 48),

              // ARConnect Card
              _AppCard(
                label: 'ARConnect',
                description: 'A Mobile Application System for Enhancing ARC Utilization in Lyceum of the Philippines – Cavite',
                accent: const Color(0xFF8B1C14),
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
              ),

              const SizedBox(height: 16),

              // SPARK Card
              _AppCard(
                label: 'SPARK',
                description: 'A Mobile Application System for Improving Access to Support Services for Single Parents in Silang, Cavite',
                accent: const Color(0xFF1A6B3C),
                icon: Icons.bolt_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SLoginPage()),
                ),
              ),

              const Spacer(),

              // Active URL display + settings button
              GestureDetector(
                onTap: _openSettings,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dns_rounded,
                          size: 16, color: Colors.white38),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppConfig.instance.baseUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_rounded,
                          size: 14, color: Colors.white24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Internal use only · Dev build',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white24,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrlExample extends StatelessWidget {
  final String label;
  final String url;
  const _UrlExample({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
          Text(
            url,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String label;
  final String description;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _AppCard({
    required this.label,
    required this.description,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: accent.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}