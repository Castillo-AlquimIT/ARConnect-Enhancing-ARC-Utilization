import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:testapp/pages/Chat/FeedChat/feedback.dart';
import 'package:testapp/pages/borrow_queue_page.dart';
import 'package:testapp/pages/Chat/FeedChat/chatbot.dart';
import 'package:testapp/pages/discussion_room_reserve.dart';

// ─────────────────────────────────────────────
// NAV BAR CONFIG
// To add a tab:    add a _NavItem to _navItems AND a case in _buildTabBody()
// To remove a tab: delete its _NavItem AND its case in _buildTabBody()
// To reorder:      move entries up/down in _navItems (update case numbers too)
// ─────────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const List<_NavItem> _navItems = [
  // ── TAB 0 ── Home / Dashboard
  _NavItem(
    activeIcon:   Icons.home_rounded,
    inactiveIcon: Icons.home_outlined,
    label: 'Home',
  ),
  // ── TAB 1 ── Library
  _NavItem(
    activeIcon:   Icons.local_library_rounded,
    inactiveIcon: Icons.local_library_outlined,
    label: 'Library',
  ),
  // ── TAB 2 ── TBA (replace icon/label when feature is decided)
  _NavItem(
    activeIcon:   Icons.explore_rounded,
    inactiveIcon: Icons.explore_outlined,
    label: 'TBA',
  ),
  // ── TAB 3 ── Profile
  _NavItem(
    activeIcon:   Icons.person_rounded,
    inactiveIcon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

// ─────────────────────────────────────────────

class DashboardPage extends StatefulWidget {

  final int    userId;
  final String numId;
  final String userName;
  final String role;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.numId,
    required this.userName,
    required this.role,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  int _currentIndex = 0;

  // ─────────────────────────────────────────────
  // TAB BODIES — add a case here for every _NavItem above
  // ─────────────────────────────────────────────
  Widget _buildTabBody() {
    switch (_currentIndex) {
      case 0:
        return _HomeTab(
          userId:   widget.userId,
          userName: widget.userName,
          role:     widget.role,
        );
      case 1:
        return _LibraryTab();
      case 2:
        return _TbaTab();
      case 3:
        return _ProfileTab(
          userName: widget.userName,
          numId:    widget.numId,
          role:     widget.role,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _buildTabBody(),
      bottomNavigationBar: _AppNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV BAR
// ─────────────────────────────────────────────
class _AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _brandRed = Color(0xFF9E0B0F);
  static const Color _inactive = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item       = _navItems[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.inactiveIcon,
                        color: isSelected ? _brandRed : _inactive,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? _brandRed : _inactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 0 — HOME
// ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {

  final int    userId;
  final String userName;
  final String role;

  const _HomeTab({
    required this.userId,
    required this.userName,
    required this.role,
  });

  static const Color _brandRed = Color(0xFF9E0B0F);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          // ── HEADER ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: const BoxDecoration(
              color: _brandRed,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $userName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),

          // ── BODY ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ── OCCUPANCY CARD ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 100,
                                showTicks: false,
                                showLabels: false,
                                startAngle: 180,
                                endAngle: 0,
                                radiusFactor: 0.9,
                                axisLineStyle: const AxisLineStyle(
                                  thickness: 0.18,
                                  thicknessUnit: GaugeSizeUnit.factor,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color: Color(0xFFEFE7E7),
                                ),
                                ranges: <GaugeRange>[
                                  GaugeRange(startValue: 0,      endValue: 34.333, color: const Color(0xFFB30000),                      startWidth: 18, endWidth: 18),
                                  GaugeRange(startValue: 34.333, endValue: 66.666, color: const Color.fromARGB(255, 245, 106, 63),       startWidth: 18, endWidth: 18),
                                  GaugeRange(startValue: 66.666, endValue: 100,    color: const Color.fromARGB(0, 255, 255, 255),        startWidth: 18, endWidth: 18),
                                ],
                                pointers: const <GaugePointer>[
                                  NeedlePointer(
                                    value: 50,
                                    needleLength: 0.65,
                                    needleStartWidth: 1,
                                    needleEndWidth: 5,
                                    knobStyle: KnobStyle(color: Colors.black, knobRadius: 0.08),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: "Occupancy: "),
                              TextSpan(text: "MODERATE (50%)", style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── GRID BUTTONS ──
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: [

                      _DashboardButton(
                        icon: Icons.book,
                        label: "Borrow Queue",
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => BorrowQueuePage(userId: userId))),
                      ),

                      _DashboardButton(
                        icon: Icons.map_outlined,
                        label: "Digital Tour",
                        onTap: () {
                          // TODO: Implement Digital Tour
                        },
                      ),

                      _DashboardButton(
                        icon: Icons.chat_bubble_outline,
                        label: "ChatBot / Feedback",
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40, height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "What would you like to do?",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 20),
                                  _BottomSheetOption(
                                    icon: Icons.smart_toy_outlined,
                                    label: "ChatBot",
                                    description: "Ask anything using AI",
                                    color: const Color(0xFF8B1C14),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => const ChatPage(
                                          apiKey: 'AIzaSyBEsEjrtMuiYuQuI2AxqfKmuFwm6AzkQfo',
                                        ),
                                      ));
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _BottomSheetOption(
                                    icon: Icons.rate_review_outlined,
                                    label: "Feedback",
                                    description: "Send us your thoughts",
                                    color: const Color(0xFF1A6B3C),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => FeedbackPage(userName: userName),
                                      ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      _DashboardButton(
                        icon: Icons.meeting_room_outlined,
                        label: "Discussion Room",
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DiscussionRoomPage(userId: userId))),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── ANNOUNCEMENTS ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Announcements",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Silence Reminder",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Attention Students. We kindly remind everyone..."),
                        SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("3 minutes ago",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8), // bottom breathing room above nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1 — LIBRARY
// Replace placeholder with your real library page
// ─────────────────────────────────────────────
class _LibraryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          "Library",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — TBA
// Replace with your real page when feature is decided
// ─────────────────────────────────────────────
class _TbaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3 — PROFILE
// Replace placeholder items with your real profile logic
// ─────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final String userName;
  final String numId;
  final String role;

  const _ProfileTab({
    required this.userName,
    required this.numId,
    required this.role,
  });

  static const Color _brandRed = Color(0xFF9E0B0F);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 48,
              backgroundColor: Color(0x1A9E0B0F),
              child: const Icon(Icons.person_rounded, size: 52, color: _brandRed),
            ),
            const SizedBox(height: 16),
            Text(userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(numId,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x1A9E0B0F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _brandRed,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _brandRed),
              title: const Text("Edit Profile"),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: navigate to edit profile page
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: _brandRed),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: navigate to change password page
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text("Logout", style: TextStyle(color: Colors.grey)),
              onTap: () {
                // TODO: call logout.php, then:
                // Navigator.pushReplacement(context,
                //   MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _DashboardButton extends StatelessWidget {

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 14),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
                      const SizedBox(height: 2),
                      Text(description,
                        style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: color.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}