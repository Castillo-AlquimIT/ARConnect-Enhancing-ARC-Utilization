import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testapp/app_config.dart';

enum DayStatus { noSchedule, available, fullyBooked, notAvailable }

class DiscussionRoomPage extends StatefulWidget {
  final int userId; // passed from DashboardPage (u_id)

  const DiscussionRoomPage({
    super.key,
    required this.userId,
  });

  @override
  State<DiscussionRoomPage> createState() => _DiscussionRoomPageState();
}

class _DiscussionRoomPageState extends State<DiscussionRoomPage> {
  static const Color _red = Color(0xFF8B1C14);

  final DateTime _today = DateTime.now();
  late DateTime _selectedDate;
  String _selectedRoom = 'Room A';
  String? _selectedSlot;
  bool _isBooking = false;

  final Map<String, DayStatus> _dayStatusCache = {};
  late int _calYear;
  late int _calMonth;

  // Time slots map to r_time_start / r_time_end in the DB
  final List<Map<String, String>> _timeSlots = [
    {'label': '8:00 AM',  'start': '08:00:00', 'end': '09:00:00'},
    {'label': '9:00 AM',  'start': '09:00:00', 'end': '10:00:00'},
    {'label': '10:00 AM', 'start': '10:00:00', 'end': '11:00:00'},
    {'label': '11:00 AM', 'start': '11:00:00', 'end': '12:00:00'},
    {'label': '1:00 PM',  'start': '13:00:00', 'end': '14:00:00'},
    {'label': '2:00 PM',  'start': '14:00:00', 'end': '15:00:00'},
    {'label': '3:00 PM',  'start': '15:00:00', 'end': '16:00:00'},
  ];

  final Set<int> _takenSlotIndices = {1, 3}; // TODO: replace with real API data

  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Room A', 'capacity': 'Up to 6 people'},
    {'name': 'Room B', 'capacity': 'Up to 10 people'},
    {'name': 'Room C', 'capacity': 'Up to 10 people'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _calYear  = _today.year;
    _calMonth = _today.month;
  }

  // Format date for DB: yyyy-MM-dd
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;

    final slot = _timeSlots.firstWhere((s) => s['label'] == _selectedSlot);

    setState(() => _isBooking = true);

    try {
      final url = Uri.parse(AppConfig.instance.url("ARConnect", "reserve_disc.php"));

      final response = await http.post(url, body: {
        "user_id":    widget.userId.toString(),   // maps to r_user_id
        "room":       _selectedRoom,              // maps to r_room
        "date":       _formatDate(_selectedDate), // maps to r_date
        "time_start": slot['start']!,             // maps to r_time_start
        "time_end":   slot['end']!,               // maps to r_time_end
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Booking submitted"),
          backgroundColor: data["status"] == "success" ? _red : Colors.grey[700],
        ),
      );

      if (data["status"] == "success") {
        setState(() => _selectedSlot = null);
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  DayStatus _getStatus(int year, int month, int day) {
    final key = '$year-$month-$day';
    if (_dayStatusCache.containsKey(key)) return _dayStatusCache[key]!;
    final date = DateTime(year, month, day);
    DayStatus status;
    if (date.isBefore(DateTime(_today.year, _today.month, _today.day))) {
      status = DayStatus.notAvailable;
    } else {
      final r = Random(key.hashCode).nextDouble();
      if (r < 0.25) {
        status = DayStatus.noSchedule;
      } else if (r < 0.55)  status = DayStatus.available;
      else if (r < 0.75)  status = DayStatus.fullyBooked;
      else                status = DayStatus.notAvailable;
    }
    _dayStatusCache[key] = status;
    return status;
  }

  Color _statusColor(DayStatus s) {
    switch (s) {
      case DayStatus.noSchedule:    return Colors.white;
      case DayStatus.available:     return const Color(0xFFFFF8E1);
      case DayStatus.fullyBooked:   return const Color(0xFFFFEBEE);
      case DayStatus.notAvailable:  return const Color(0xFFF5F5F5);
    }
  }

  Color _statusBorderColor(DayStatus s) {
    switch (s) {
      case DayStatus.noSchedule:    return const Color(0xFFDDDDDD);
      case DayStatus.available:     return const Color(0xFFFFD54F);
      case DayStatus.fullyBooked:   return const Color(0xFFEF9A9A);
      case DayStatus.notAvailable:  return const Color(0xFFE0E0E0);
    }
  }

  Color _statusTextColor(DayStatus s) {
    switch (s) {
      case DayStatus.noSchedule:    return const Color(0xFF1A1A1A);
      case DayStatus.available:     return const Color(0xFF7A5C00);
      case DayStatus.fullyBooked:   return const Color(0xFF7F0000);
      case DayStatus.notAvailable:  return const Color(0xFFAAAAAA);
    }
  }

  void _openCalendar() {
    setState(() {
      _calYear  = _today.year;
      _calMonth = _today.month;
    });
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setModal(() {
                        _calMonth--;
                        if (_calMonth < 1) { _calMonth = 12; _calYear--; }
                      }),
                    ),
                    Text(
                      '${_monthName(_calMonth)} $_calYear',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setModal(() {
                        _calMonth++;
                        if (_calMonth > 12) { _calMonth = 1; _calYear++; }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Su','Mo','Tu','We','Th','Fr','Sa']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                _buildCalendarGrid(setModal),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildLegend(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(StateSetter setModal) {
    final firstWeekday = DateTime(_calYear, _calMonth, 1).weekday % 7;
    final daysInMonth  = DateTime(_calYear, _calMonth + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: firstWeekday + daysInMonth,
      itemBuilder: (_, i) {
        if (i < firstWeekday) return const SizedBox.shrink();
        final day    = i - firstWeekday + 1;
        final status = _getStatus(_calYear, _calMonth, day);
        final isToday = day == _today.day &&
            _calMonth == _today.month &&
            _calYear == _today.year;

        return Container(
          decoration: BoxDecoration(
            color: _statusColor(status),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday ? _red : _statusBorderColor(status),
              width: isToday ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _statusTextColor(status),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    const items = [
      {'label': 'No schedule',   'bg': Color(0xFFFFFFFF), 'border': Color(0xFFDDDDDD)},
      {'label': 'Available',     'bg': Color(0xFFFFF8E1), 'border': Color(0xFFFFD54F)},
      {'label': 'Fully booked',  'bg': Color(0xFFFFEBEE), 'border': Color(0xFFEF9A9A)},
      {'label': 'Not available', 'bg': Color(0xFFF5F5F5), 'border': Color(0xFFE0E0E0)},
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: item['bg'] as Color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: item['border'] as Color, width: 1.5),
            ),
          ),
          const SizedBox(width: 5),
          Text(item['label'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
        ],
      )).toList(),
    );
  }

  String _monthName(int m) {
    const names = ['','January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return names[m];
  }

  String _monthShort(int m) {
    const names = ['','Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m];
  }

  String _dayShort(int weekday) {
    const names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Discussion Room Reservation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _openCalendar,
            tooltip: 'View calendar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateStrip(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Select a room'),
                  const SizedBox(height: 10),
                  ..._rooms.map((r) => _buildRoomCard(r)),
                  const SizedBox(height: 18),
                  _buildSectionLabel('Available time slots'),
                  const SizedBox(height: 10),
                  _buildSlots(),
                  const SizedBox(height: 20),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: List.generate(3, (i) {
          final d = _today.add(Duration(days: i));
          final isSelected = d.year == _selectedDate.year &&
              d.month == _selectedDate.month &&
              d.day == _selectedDate.day;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedDate = d;
                _selectedSlot = null;
              }),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? _red : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _red : const Color(0xFFEEEEEE),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _monthShort(d.month).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: isSelected ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _dayShort(d.weekday).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white60 : Colors.grey,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: Colors.grey, letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final isSelected = _selectedRoom == room['name'];
    return GestureDetector(
      onTap: () => setState(() => _selectedRoom = room['name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _red : const Color(0xFFEEEEEE),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.meeting_room_outlined,
                color: Color(0x66FFFFFF), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(room['capacity'],
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _red : Colors.white,
                border: Border.all(
                  color: isSelected ? _red : const Color(0xFFDDDDDD),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_timeSlots.length, (i) {
        final isTaken    = _takenSlotIndices.contains(i);
        final label      = _timeSlots[i]['label']!;
        final isSelected = _selectedSlot == label;
        return GestureDetector(
          onTap: isTaken ? null : () => setState(() => _selectedSlot = label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _red : isTaken ? const Color(0xFFF5F5F5) : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isSelected ? _red : const Color(0xFFEEEEEE),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isTaken
                        ? const Color(0xFFCCCCCC)
                        : const Color(0xFF555555),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: (_selectedSlot == null || _isBooking) ? null : _confirmBooking,
        child: _isBooking
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}