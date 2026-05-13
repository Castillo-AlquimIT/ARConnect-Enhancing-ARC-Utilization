import 'package:flutter/material.dart';

class SDashboardPage extends StatefulWidget {
  final String userName;
  const SDashboardPage({super.key, required this.userName});

  @override
  State<SDashboardPage> createState() => _SDashboardPageState();
}

class _SDashboardPageState extends State<SDashboardPage> {
  static const Color _purple = Color(0xFF6C47C9);
  int _selectedNav = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.work_outline_rounded, 'label': 'Find Jobs', 'filled': true},
    {'icon': Icons.favorite_border_rounded, 'label': 'Welfare Benefits', 'filled': false},
    {'icon': Icons.child_friendly_outlined, 'label': 'Childcare Finder', 'filled': false},
    {'icon': Icons.group_outlined, 'label': 'Community Forum', 'filled': false},
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'New Childcare Grant Applications Open',
      'date': 'Apr 10, 2024',
      'color': Color(0xFF7C5CBF),
      'icon': Icons.article_outlined,
    },
    {
      'title': 'Free Financial Workshop: Nov 15th',
      'date': 'Nov 15, 2024',
      'color': Color(0xFF4A7FC1),
      'icon': Icons.event_outlined,
    },
    {
      'title': 'Parenting Balance & Wellbeing',
      'date': 'Nov 21, 2024',
      'color': Color(0xFF5B8A6A),
      'icon': Icons.menu_book_outlined,
    },
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.work_outline, 'label': 'Jobs'},
    {'icon': Icons.folder_outlined, 'label': 'Resources'},
    {'icon': Icons.group_outlined, 'label': 'Community'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildGrid(),
                    _buildSectionLabel('Local Updates & Events'),
                    _buildEvents(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD4C5F5),
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B3FB5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${widget.userName}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          // Notification button
          Stack(
            children: [
              Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0EAFF),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: _purple,
                  size: 20,
                ),
              ),
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey, size: 20),
          SizedBox(width: 10),
          Text(
            'Search jobs, resources, childcare...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        children: _menuItems.map((item) => _buildMenuCard(item)).toList(),
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    final bool filled = item['filled'] as bool;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: filled ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              item['icon'] as IconData,
              size: 28,
              color: filled ? Colors.white : _purple,
            ),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: filled ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildEvents() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _buildEventCard(_events[i]),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: event['color'] as Color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Center(
              child: Icon(
                event['icon'] as IconData,
                color: Colors.white.withValues(alpha: 0.5),
                size: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  event['date'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Read More',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final isActive = _selectedNav == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedNav = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _navItems[i]['icon'] as IconData,
                    size: 22,
                    color: isActive ? _purple : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _navItems[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? _purple : Colors.grey.shade400,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 4, height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _purple,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}