import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 's_login_page.dart';
import 'dart:convert';
import 'package:testapp/app_config.dart';

// ─── theme constants ───────────────────────────────────────────────────────────
const _purple       = Color(0xFF7C6EE6);
const _purpleLight  = Color(0xFFF3F0FF);
const _purpleMuted  = Color(0xFFA89CC8);
const _purpleBorder = Color(0xFFD5C9F5);
const _green        = Color(0xFF4CAF50);
const _red          = Color(0xFFE53935);
const _amber        = Color(0xFFFFA000);

// ─── main admin page ───────────────────────────────────────────────────────────
class SAdminPage extends StatefulWidget {
  final String adminName;
  final int    adminId;

  const SAdminPage({
    super.key,
    required this.adminName,
    required this.adminId,
  });

  @override
  State<SAdminPage> createState() => _SAdminPageState();
}

class _SAdminPageState extends State<SAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purpleLight,
      appBar: AppBar(
        backgroundColor: _purple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SPARK Admin",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2)),
            Text("Welcome, ${widget.adminName}",
                style: const TextStyle(
                    fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Colors.white, size: 20),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.people_outline, size: 18), text: "Users"),
            Tab(icon: Icon(Icons.folder_outlined, size: 18), text: "Documents"),
            Tab(icon: Icon(Icons.child_care_outlined, size: 18), text: "Children"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsersTab(adminId: widget.adminId),
          _DocumentsTab(adminId: widget.adminId),
          _ChildrenTab(adminId: widget.adminId),
        ],
      ),
    );
  }
}

// ─── shared helpers ────────────────────────────────────────────────────────────
Widget _statusBadge(String status) {
  Color bg;
  Color fg;
  switch (status) {
    case 'verified':
    case 'approved':
      bg = const Color(0xFFE8F5E9); fg = _green; break;
    case 'rejected':
      bg = const Color(0xFFFFEBEE); fg = _red;   break;
    default:
      bg = const Color(0xFFFFF8E1); fg = _amber;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: fg),
    ),
  );
}

Widget _infoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

// ─────────────────────────────────────────────────────────────────────────────
//  USERS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  final int adminId;
  const _UsersTab({required this.adminId});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<dynamic> _users     = [];
  bool          _loading   = true;
  String        _filter    = 'all'; // all | pending | verified | rejected

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final url = Uri.parse(
        AppConfig.instance.url("Spark", "admin_get_users.php"));
    try {
      final res = await http
          .get(url)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["status"] == "success") {
          setState(() => _users = data["users"]);
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<dynamic> get _filtered {
    if (_filter == 'all') return _users;
    return _users.where((u) =>
        (u["verification_status"] ?? 'pending') == _filter).toList();
  }

  Future<void> _updateVerification(
      int userId, String status, String? reason) async {
    final url = Uri.parse(
        AppConfig.instance.url("Spark", "admin_update_verification.php"));
    try {
      final res = await http.post(url, body: {
        "user_id"          : userId.toString(),
        "status"           : status,
        "rejection_reason" : reason ?? '',
        "admin_id"         : widget.adminId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (data["status"] == "success") _fetchUsers();
      }
    } catch (_) {}
  }

  void _showUserDetail(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UserDetailSheet(
        user: user,
        adminId: widget.adminId,
        onUpdate: (status, reason) {
          Navigator.pop(context);
          _updateVerification(user["id"], status, reason);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteUser(user["id"]);
        },
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: const Text(
            "This will permanently delete the user and all their data."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete",
                  style: TextStyle(color: _red))),
        ],
      ),
    );
    if (confirm != true) return;

    final url =
        Uri.parse(AppConfig.instance.url("Spark", "admin_crud.php"));
    try {
      final res = await http.post(url, body: {
        "action"    : "delete_user",
        "target_id" : userId.toString(),
        "admin_id"  : widget.adminId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      final data = json.decode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"]),
              behavior: SnackBarBehavior.floating));
      if (data["status"] == "success") _fetchUsers();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['all', 'pending', 'verified', 'rejected']
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.toUpperCase(),
                            style: const TextStyle(fontSize: 11)),
                        selected: _filter == f,
                        selectedColor: _purple,
                        labelStyle: TextStyle(
                          color: _filter == f
                              ? Colors.white
                              : _purpleMuted,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) =>
                            setState(() => _filter = f),
                      ),
                    ))
                .toList(),
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _purple))
              : RefreshIndicator(
                  color: _purple,
                  onRefresh: _fetchUsers,
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text("No users found.",
                              style: TextStyle(color: _purpleMuted)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final u = _filtered[i];
                            final status =
                                u["verification_status"] ?? 'pending';
                            return GestureDetector(
                              onTap: () => _showUserDetail(u),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _purpleBorder,
                                      width: 1),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: _purpleLight,
                                      child: Text(
                                        (u["f_name"] ?? '?')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: _purple,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${u["f_name"]} ${u["l_name"]}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(u["email"] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: _purpleMuted)),
                                          const SizedBox(height: 4),
                                          Text(
                                            (u["solo_parent_type"] ?? '')
                                                .replaceAll('_', ' '),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: _purpleMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _statusBadge(status),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

// ─── user detail bottom sheet ─────────────────────────────────────────────────
class _UserDetailSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  final int adminId;
  final Function(String status, String? reason) onUpdate;
  final VoidCallback onDelete;

  const _UserDetailSheet({
    required this.user,
    required this.adminId,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _confirmReject() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject User",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: _reasonCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Reason for rejection...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onUpdate('rejected', _reasonCtrl.text.trim());
              },
              child: const Text("Confirm Reject",
                  style: TextStyle(color: _red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u      = widget.user;
    final status = u["verification_status"] ?? 'pending';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _purpleBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _purpleLight,
                  child: Text(
                    (u["f_name"] ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${u["f_name"]} ${u["m_name"] ?? ''} ${u["l_name"]} ${u["suffix"] ?? ''}"
                            .trim(),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      _statusBadge(status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle("Account"),
            _infoRow("Email", u["email"] ?? ''),
            _infoRow("Occupation", u["occupation"] ?? ''),
            _infoRow("Registered", u["created_at"] ?? ''),

            const SizedBox(height: 14),
            _sectionTitle("Solo Parent Profile"),
            _infoRow("Type",
                (u["solo_parent_type"] ?? '').replaceAll('_', ' ')),
            _infoRow("Civil Status",
                (u["civil_status"] ?? '').replaceAll('_', ' ')),
            _infoRow("Barangay", u["barangay"] ?? ''),
            _infoRow("City", u["city"] ?? ''),
            _infoRow("Province", u["province"] ?? ''),

            if (status == 'rejected' &&
                (u["rejection_reason"] ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionTitle("Rejection Reason"),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(u["rejection_reason"],
                    style: const TextStyle(
                        fontSize: 12, color: _red)),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            if (status != 'verified')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline,
                      size: 18),
                  label: const Text("Verify User"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => widget.onUpdate('verified', null),
                ),
              ),

            if (status != 'rejected') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined,
                      size: 18, color: _red),
                  label: const Text("Reject",
                      style: TextStyle(color: _red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _red, width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _confirmReject,
                ),
              ),
            ],

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: _purpleMuted),
                label: const Text("Delete User",
                    style: TextStyle(color: _purpleMuted)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: _purpleBorder, width: 1.5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.onDelete,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _purple,
              letterSpacing: 0.5)),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  DOCUMENTS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentsTab extends StatefulWidget {
  final int adminId;
  const _DocumentsTab({required this.adminId});

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  List<dynamic> _docs    = [];
  bool          _loading = true;
  String        _filter  = 'all';

  @override
  void initState() {
    super.initState();
    _fetchDocs();
  }

  Future<void> _fetchDocs() async {
    setState(() => _loading = true);
    final url = Uri.parse(
        AppConfig.instance.url("Spark", "admin_get_documents.php"));
    try {
      final res =
          await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["status"] == "success") {
          setState(() => _docs = data["documents"]);
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<dynamic> get _filtered {
    if (_filter == 'all') return _docs;
    return _docs
        .where((d) => (d["status"] ?? 'pending') == _filter)
        .toList();
  }

  Future<void> _updateDoc(
      int docId, String status, String remarks) async {
    final url = Uri.parse(
        AppConfig.instance.url("Spark", "admin_update_document.php"));
    try {
      final res = await http.post(url, body: {
        "doc_id"   : docId.toString(),
        "status"   : status,
        "remarks"  : remarks,
        "admin_id" : widget.adminId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      final data = json.decode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data["message"]),
          behavior: SnackBarBehavior.floating));
      if (data["status"] == "success") _fetchDocs();
    } catch (_) {}
  }

  void _showDocDetail(Map<String, dynamic> doc) {
    final remarksCtrl = TextEditingController(text: doc["remarks"] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: _purpleBorder,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              _sectionTitle("Document Details"),
              _infoRow("Type",
                  (doc["document_type"] ?? '').replaceAll('_', ' ')),
              _infoRow("Uploaded by",
                  "${doc["f_name"]} ${doc["l_name"]}"),
              _infoRow("File", doc["file_name"] ?? ''),
              _infoRow("Uploaded", doc["uploaded_at"] ?? ''),
              _infoRow("Status", doc["status"] ?? ''),
              const SizedBox(height: 16),

              TextField(
                controller: remarksCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Remarks (optional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _purple, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateDoc(doc["id"], 'approved',
                          remarksCtrl.text.trim());
                    },
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _red, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateDoc(doc["id"], 'rejected',
                          remarksCtrl.text.trim());
                    },
                    child: const Text("Reject",
                        style: TextStyle(color: _red)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['all', 'pending', 'approved', 'rejected']
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.toUpperCase(),
                            style: const TextStyle(fontSize: 11)),
                        selected: _filter == f,
                        selectedColor: _purple,
                        labelStyle: TextStyle(
                          color: _filter == f
                              ? Colors.white
                              : _purpleMuted,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) =>
                            setState(() => _filter = f),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _purple))
              : RefreshIndicator(
                  color: _purple,
                  onRefresh: _fetchDocs,
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text("No documents found.",
                              style: TextStyle(color: _purpleMuted)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final d = _filtered[i];
                            return GestureDetector(
                              onTap: () => _showDocDetail(d),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _purpleBorder,
                                      width: 1),
                                ),
                                child: Row(children: [
                                  const Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: _purple,
                                      size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (d["document_type"] ?? '')
                                              .replaceAll('_', ' '),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${d["f_name"]} ${d["l_name"]}",
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: _purpleMuted),
                                        ),
                                        Text(
                                          d["file_name"] ?? '',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: _purpleMuted),
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _statusBadge(
                                      d["status"] ?? 'pending'),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHILDREN TAB
// ─────────────────────────────────────────────────────────────────────────────
class _ChildrenTab extends StatefulWidget {
  final int adminId;
  const _ChildrenTab({required this.adminId});

  @override
  State<_ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends State<_ChildrenTab> {
  List<dynamic> _children = [];
  bool          _loading  = true;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() => _loading = true);
    final url = Uri.parse(
        AppConfig.instance.url("Spark", "admin_get_children.php"));
    try {
      final res =
          await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["status"] == "success") {
          setState(() => _children = data["children"]);
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _deleteChild(int childId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
        content: const Text(
            "Are you sure you want to delete this child record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete",
                  style: TextStyle(color: _red))),
        ],
      ),
    );
    if (confirm != true) return;

    final url =
        Uri.parse(AppConfig.instance.url("Spark", "admin_crud.php"));
    try {
      final res = await http.post(url, body: {
        "action"    : "delete_child",
        "target_id" : childId.toString(),
        "admin_id"  : widget.adminId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      final data = json.decode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data["message"]),
          behavior: SnackBarBehavior.floating));
      if (data["status"] == "success") _fetchChildren();
    } catch (_) {}
  }

  void _showChildDetail(Map<String, dynamic> child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: _purpleBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            _sectionTitle("Child Record"),
            _infoRow("Name",
                "${child["f_name"]} ${child["m_name"] ?? ''} ${child["l_name"]}"
                    .trim()),
            _infoRow("Birthdate", child["birthdate"] ?? ''),
            _infoRow("Sex", child["sex"] ?? ''),
            _infoRow("School", child["school"] ?? ''),
            _infoRow("Grade Level", child["grade_level"] ?? ''),
            _infoRow("Disability",
                child["with_disability"] == "1" ? "Yes" : "No"),
            if (child["with_disability"] == "1")
              _infoRow("Details", child["disability_details"] ?? ''),
            _infoRow("Parent",
                "${child["parent_f_name"]} ${child["parent_l_name"]}"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: _red),
                label: const Text("Delete Record",
                    style: TextStyle(color: _red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _red, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteChild(child["id"]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _age(String? birthdate) {
    if (birthdate == null) return 0;
    try {
      final b = DateTime.parse(birthdate);
      final now = DateTime.now();
      int age = now.year - b.year;
      if (now.month < b.month ||
          (now.month == b.month && now.day < b.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(color: _purple))
        : RefreshIndicator(
            color: _purple,
            onRefresh: _fetchChildren,
            child: _children.isEmpty
                ? const Center(
                    child: Text("No children records found.",
                        style: TextStyle(color: _purpleMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _children.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = _children[i];
                      final age = _age(c["birthdate"]);
                      return GestureDetector(
                        onTap: () => _showChildDetail(c),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                                color: _purpleBorder, width: 1),
                          ),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _purpleLight,
                              child: Text(
                                "${age}y",
                                style: const TextStyle(
                                    color: _purple,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${c["f_name"]} ${c["l_name"]}",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Parent: ${c["parent_f_name"]} ${c["parent_l_name"]}",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: _purpleMuted),
                                  ),
                                  if (c["school"] != null &&
                                      (c["school"] as String)
                                          .isNotEmpty)
                                    Text(
                                      c["school"],
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: _purpleMuted),
                                    ),
                                ],
                              ),
                            ),
                            if (c["with_disability"] == "1")
                              const Icon(
                                  Icons.accessibility_new_outlined,
                                  size: 16,
                                  color: _amber),
                          ]),
                        ),
                      );
                    },
                  ),
          );
  }
}