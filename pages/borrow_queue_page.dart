import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testapp/app_config.dart';

class BorrowQueuePage extends StatefulWidget {
  final int userId; // passed from DashboardPage

  const BorrowQueuePage({
    super.key,
    required this.userId,
  });

  @override
  State<BorrowQueuePage> createState() => _BorrowQueuePageState();
}

class _BorrowQueuePageState extends State<BorrowQueuePage> {

  bool   _isLoading  = true;   // initial fetch
  bool   _isBusy     = false;  // ANY network call in progress — blocks all buttons
  bool   _hasTicket  = false;

  int?   _ticketId;
  String _queueNumber = '—';
  String _status      = 'Not issued';
  String _estWait     = '—';

  final List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    // Generate static barcode bars once
    final rng = Random();
    _barHeights.addAll(List.generate(17, (_) => rng.nextInt(10).toDouble() + 4));
    _fetchTicket();
  }

  Uri get _url => Uri.parse(AppConfig.instance.url("ARConnect", "borrow_queue.php"));

  // ── Load existing ticket on page open ──
  Future<void> _fetchTicket() async {
    if (_isBusy) return;
    setState(() { _isLoading = true; _isBusy = true; });
    try {
      final response = await http.post(_url, body: {
        "action":  "get_ticket",
        "user_id": widget.userId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = json.decode(response.body);
      if (data["status"] == "success") {
        final ticket = data["ticket"];
        if (ticket != null) {
          _applyTicket(ticket);
        } else {
          _clearTicket();
        }
      }
    } catch (_) {
      // silently fail — user sees the empty state
    } finally {
      if (mounted) setState(() { _isLoading = false; _isBusy = false; });
    }
  }

  // ── Issue a new ticket ──
  Future<void> _issueTicket() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final response = await http.post(_url, body: {
        "action":  "issue_ticket",
        "user_id": widget.userId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Something went wrong")),
      );

      if (data["status"] == "success") {
        _applyTicket(data["ticket"]);
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // ── Cancel the active ticket ──
  Future<void> _cancelTicket() async {
    if (_ticketId == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final response = await http.post(_url, body: {
        "action":    "cancel_ticket",
        "user_id":   widget.userId.toString(),
        "ticket_id": _ticketId.toString(),
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Something went wrong")),
      );

      if (data["status"] == "success") {
        _clearTicket();
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _applyTicket(Map<String, dynamic> ticket) {
    _ticketId    = ticket["id"];
    _queueNumber = ticket["number"]   ?? '—';
    _status      = ticket["status"]   ?? '—';
    _estWait     = ticket["est_wait"] ?? '—';
    _hasTicket   = true;
  }

  void _clearTicket() {
    _ticketId    = null;
    _queueNumber = '—';
    _status      = 'Not issued';
    _estWait     = '—';
    _hasTicket   = false;
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C14),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Borrowing Queue',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading || _isBusy ? null : _fetchTicket,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B1C14)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTicket(),
                  const SizedBox(height: 24),
                  _buildButton(),
                  const SizedBox(height: 24),
                  _buildMessageBox(),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────
  // TICKET CARD
  // ─────────────────────────────────────────
  Widget _buildTicket() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B1C14), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            _buildTicketHeader(),
            _buildTicketDivider(),
            _buildTicketBody(),
            _buildTicketFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF8B1C14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'DIGITAL TICKET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            'Library',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDivider() {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          _buildNotch(isLeft: true),
          Expanded(child: CustomPaint(painter: _DashedLinePainter())),
          _buildNotch(isLeft: false),
        ],
      ),
    );
  }

  Widget _buildNotch({required bool isLeft}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFF8B1C14), width: 1.5),
      ),
      transform: Matrix4.translationValues(isLeft ? -10 : 10, 0, 0),
    );
  }

  Widget _buildTicketBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            _queueNumber,
            style: const TextStyle(
              fontSize: 52,
              color: Color(0xFF8B1C14),
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'QUEUE NUMBER',
            style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMetaItem(label: 'STATUS',    value: _status),
          _buildMetaItem(label: 'EST. WAIT', value: _estWait, alignEnd: true),
          _buildBarcode(),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required String label,
    required String value,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildBarcode() {
    return SizedBox(
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _barHeights.map((h) => Container(
          width: 2,
          height: h,
          margin: const EdgeInsets.only(right: 2),
          color: Colors.black.withValues(alpha: 0.3),
        )).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // ACTION BUTTON
  // ─────────────────────────────────────────
  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: _hasTicket
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B1C14),
                side: const BorderSide(color: Color(0xFF8B1C14), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isBusy ? null : _cancelTicket,
              icon: _isBusy
                  ? const SizedBox(height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B1C14)))
                  : const Icon(Icons.close),
              label: const Text('Cancel Ticket',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1C14),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isBusy ? null : _issueTicket,
              icon: _isBusy
                  ? const SizedBox(height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.confirmation_number_outlined),
              label: const Text('Get Digital Ticket',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
    );
  }

  // ─────────────────────────────────────────
  // MESSAGE BOX
  // ─────────────────────────────────────────
  Widget _buildMessageBox() {
    final title = _hasTicket ? 'You are in the queue!' : "You'll be notified here";
    final body  = _hasTicket
        ? "Your ticket has been issued. We will notify you once it's your turn."
        : "Please wait. We will notify you once it's your turn to borrow.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B1C14).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF8B1C14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(body,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// DASHED LINE PAINTER
// ─────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B1C14).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}