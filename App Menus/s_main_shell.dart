// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 's_home_page.dart';
import 's_my_jobs_page.dart';
import 's_resources_page.dart';
import 's_community_page.dart';
import 's_profile_page.dart';

class SMainShell extends StatefulWidget {
  final String userName;
  final int    userId;

  const SMainShell({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<SMainShell> createState() => _SMainShellState();
}

class _SMainShellState extends State<SMainShell> {
  int _currentIndex = 0;

  static const _purple      = Color(0xFF7C6EE6);
  static const _purpleLight = Color(0xFFF3F0FF);
  static const _purpleMuted = Color(0xFFA89CC8);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SHomePage(
        userName: widget.userName,
        userId: widget.userId,
        onFindJobTap: () => setState(() => _currentIndex = 1),
      ),
      SMyJobsPage(userId: widget.userId),
      SResourcesPage(userId: widget.userId),
      SCommunityPage(userId: widget.userId),
      SProfilePage(
        userName: widget.userName,
        userId: widget.userId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
                _NavItem(
                  icon: Icons.work_outline_rounded,
                  activeIcon: Icons.work_rounded,
                  label: "My Jobs",
                  index: 1,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
                _NavItem(
                  icon: Icons.library_books_outlined,
                  activeIcon: Icons.library_books_rounded,
                  label: "Resources",
                  index: 2,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
                _NavItem(
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum_rounded,
                  label: "Community",
                  index: 3,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "Profile",
                  index: 4,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── nav item widget ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData   icon;
  final IconData   activeIcon;
  final String     label;
  final int        index;
  final int        currentIndex;
  final ValueChanged<int> onTap;

  static const _purple      = Color(0xFF7C6EE6);
  static const _purpleMuted = Color(0xFFA89CC8);

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? _purple.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? _purple : _purpleMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? _purple : _purpleMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
