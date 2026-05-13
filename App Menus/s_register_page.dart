import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 's_dashboard.dart';
import 'dart:convert';
import 'package:testapp/app_config.dart';

// ─── constants ────────────────────────────────────────────────────────────────
const _purple       = Color(0xFF7C6EE6);
const _purpleLight  = Color(0xFFF3F0FF);
const _purpleMuted  = Color(0xFFA89CC8);
const _purpleBorder = Color(0xFFD5C9F5);

const _soloParentTypes = [
  'unmarried',
  'separated',
  'annulled',
  'widowed',
  'spouse_detained',
  'spouse_disabled',
  'spouse_mia',
];

const _civilStatuses = [
  'single',
  'married',
  'separated',
  'widowed',
  'annulled',
];

// ─── widget ───────────────────────────────────────────────────────────────────
class SRegisterPage extends StatefulWidget {
  const SRegisterPage({super.key});

  @override
  State<SRegisterPage> createState() => _SRegisterPageState();
}

class _SRegisterPageState extends State<SRegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading  = false;

  // ── Step 1: Account info ────────────────────────────────────────────────────
  final _fNameCtrl  = TextEditingController();
  final _mNameCtrl  = TextEditingController();
  final _lNameCtrl  = TextEditingController();
  final _suffixCtrl = TextEditingController();
  final _occCtrl    = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();
  bool _obscurePass     = true;
  bool _obscureConfirm  = true;

  // ── Step 2: Solo parent profile ─────────────────────────────────────────────
  String? _soloParentType;
  String? _civilStatus;
  final _barangayCtrl = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _provinceCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _fNameCtrl, _mNameCtrl, _lNameCtrl, _suffixCtrl, _occCtrl,
      _emailCtrl, _passCtrl, _confirmCtrl,
      _barangayCtrl, _cityCtrl, _provinceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── helpers ─────────────────────────────────────────────────────────────────
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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

  Widget _dropdownField({
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: _fieldDecor(hint, icon),
      hint: Text(hint,
          style: const TextStyle(color: _purpleBorder, fontSize: 13)),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 13),
                ),
              ))
          .toList(),
    );
  }

  // ── step validation ──────────────────────────────────────────────────────────
  bool _validateStep1() {
    if (_fNameCtrl.text.trim().isEmpty ||
        _lNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      _showSnack("Please fill in all required fields.");
      return false;
    }
    if (!_emailCtrl.text.contains('@')) {
      _showSnack("Please enter a valid email address.");
      return false;
    }
    if (_passCtrl.text.length < 8) {
      _showSnack("Password must be at least 8 characters.");
      return false;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _showSnack("Passwords do not match.");
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_soloParentType == null || _civilStatus == null) {
      _showSnack("Please select your solo parent type and civil status.");
      return false;
    }
    if (_barangayCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _provinceCtrl.text.trim().isEmpty) {
      _showSnack("Please fill in your complete address.");
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;

    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ── submit ───────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(AppConfig.instance.url("Spark", "register.php"));
    try {
      final response = await http.post(url, body: {
        // account
        "f_name"   : _fNameCtrl.text.trim(),
        "m_name"   : _mNameCtrl.text.trim(),
        "l_name"   : _lNameCtrl.text.trim(),
        "suffix"   : _suffixCtrl.text.trim(),
        "occupation": _occCtrl.text.trim(),
        "email"    : _emailCtrl.text.trim(),
        "password" : _passCtrl.text,
        // profile
        "solo_parent_type": _soloParentType ?? '',
        "civil_status"    : _civilStatus ?? '',
        "barangay"        : _barangayCtrl.text.trim(),
        "city"            : _cityCtrl.text.trim(),
        "province"        : _provinceCtrl.text.trim(),
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSnack(data["message"]);

        if (data["status"] == "success") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SDashboardPage(userName: _fNameCtrl.text.trim()),
            ),
            (route) => false,
          );
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

  // ── step indicator ───────────────────────────────────────────────────────────
  Widget _stepIndicator() {
    const labels = ["Account", "Profile", "Confirm"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final done   = i < _currentStep;
        final active = i == _currentStep;
        return Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done || active ? _purple : Colors.white,
                    border: Border.all(
                      color: done || active ? _purple : _purpleBorder,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            "${i + 1}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : _purpleMuted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? _purple : _purpleMuted,
                  ),
                ),
              ],
            ),
            if (i < labels.length - 1)
              Container(
                width: 40,
                height: 1.5,
                margin: const EdgeInsets.only(bottom: 18),
                color: i < _currentStep ? _purple : _purpleBorder,
              ),
          ],
        );
      }),
    );
  }

  // ── pages ────────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text("Personal Information",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const SizedBox(height: 4),
          const Text("Tell us your basic details.",
              style: TextStyle(fontSize: 11, color: _purpleMuted)),
          const SizedBox(height: 20),

          // Name row
          Row(children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _fNameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: _fieldDecor("First name *", Icons.person_outline),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _mNameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: _fieldDecor("Middle", Icons.person_outline),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _lNameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: _fieldDecor("Last name *", Icons.person_outline),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _suffixCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: _fieldDecor("Suffix", Icons.person_outline),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          TextField(
            controller: _occCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor("Occupation", Icons.work_outline),
          ),
          const SizedBox(height: 20),

          const Text("Account Credentials",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const SizedBox(height: 16),

          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor("Email address *", Icons.email_outlined),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor(
              "Password * (min. 8 chars)",
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _purpleMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor(
              "Confirm password *",
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _purpleMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text("Solo Parent Classification",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const SizedBox(height: 4),
          const Text(
            "This determines your eligibility under RA 8972.",
            style: TextStyle(fontSize: 11, color: _purpleMuted),
          ),
          const SizedBox(height: 20),

          _dropdownField(
            hint: "Solo parent type *",
            icon: Icons.family_restroom,
            items: _soloParentTypes,
            value: _soloParentType,
            onChanged: (v) => setState(() => _soloParentType = v),
          ),
          const SizedBox(height: 12),

          _dropdownField(
            hint: "Civil status *",
            icon: Icons.favorite_border,
            items: _civilStatuses,
            value: _civilStatus,
            onChanged: (v) => setState(() => _civilStatus = v),
          ),
          const SizedBox(height: 24),

          const Text("Address",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const SizedBox(height: 16),

          TextField(
            controller: _barangayCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor("Barangay *", Icons.location_on_outlined),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _cityCtrl,
            style: const TextStyle(fontSize: 13),
            decoration:
                _fieldDecor("City / Municipality *", Icons.location_city_outlined),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _provinceCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDecor("Province *", Icons.map_outlined),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: _purpleMuted)),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? "—" : value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text("Review your details",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const SizedBox(height: 4),
          const Text("Make sure everything looks correct before submitting.",
              style: TextStyle(fontSize: 11, color: _purpleMuted)),
          const SizedBox(height: 20),

          // Account section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _purpleBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Account",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                        letterSpacing: 0.5)),
                const Divider(height: 16, color: _purpleBorder),
                row("Name",
                    "${_fNameCtrl.text} ${_mNameCtrl.text} ${_lNameCtrl.text} ${_suffixCtrl.text}"
                        .trim()),
                row("Occupation", _occCtrl.text.trim()),
                row("Email", _emailCtrl.text.trim()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Profile section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _purpleBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Solo Parent Profile",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                        letterSpacing: 0.5)),
                const Divider(height: 16, color: _purpleBorder),
                row("Type",
                    (_soloParentType ?? '').replaceAll('_', ' ')),
                row("Civil status",
                    (_civilStatus ?? '').replaceAll('_', ' ')),
                row("Barangay", _barangayCtrl.text.trim()),
                row("City", _cityCtrl.text.trim()),
                row("Province", _provinceCtrl.text.trim()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082), width: 1),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Your account will be pending verification. "
                    "A social worker will review your profile before "
                    "full access is granted.",
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF7A6000)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const steps = 3;
    final isLast = _currentStep == steps - 1;

    return Scaffold(
      backgroundColor: _purpleLight,
      appBar: AppBar(
        backgroundColor: _purpleLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _purple),
          onPressed: _isLoading ? null : _prevStep,
        ),
        title: const Text(
          "SPARK",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _purple,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _stepIndicator(),
          const SizedBox(height: 20),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Bottom button
          Padding(
            padding:
                const EdgeInsets.fromLTRB(28, 12, 28, 28),
            child: SizedBox(
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
                onPressed: _isLoading
                    ? null
                    : isLast
                        ? _submit
                        : _nextStep,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isLast ? "Submit Registration" : "Next",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}