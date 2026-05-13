// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class SHomePage extends StatelessWidget {
  final String    userName;
  final int       userId;
  final VoidCallback onFindJobTap;

  const SHomePage({
    super.key,
    required this.userName,
    required this.userId,
    required this.onFindJobTap,
  });

  static const _purple       = Color(0xFF7C6EE6);
  static const _purpleLight  = Color(0xFFF3F0FF);
  static const _purpleMuted  = Color(0xFFA89CC8);
  static const _purpleBorder = Color(0xFFD5C9F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purpleLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $userName 👋",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "What do you need today?",
                        style: TextStyle(
                            fontSize: 12, color: _purpleMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: _purple),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Find Job Banner ──────────────────────────────────────────────
              GestureDetector(
                onTap: onFindJobTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6EE6), Color(0xFF9B8FF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Find a Job",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Browse opportunities\nfor solo parents",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Search Jobs →",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.work_outline_rounded,
                          size: 64, color: Colors.white24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Access ─────────────────────────────────────────────────
              const Text(
                "Quick Access",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _purple),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: const [
                  _QuickCard(
                      icon: Icons.attach_money_rounded,
                      label: "Financial\nSupport",
                      color: Color(0xFFE8F5E9),
                      iconColor: Color(0xFF4CAF50)),
                  _QuickCard(
                      icon: Icons.home_outlined,
                      label: "Home\nAssistance",
                      color: Color(0xFFE3F2FD),
                      iconColor: Color(0xFF1E88E5)),
                  _QuickCard(
                      icon: Icons.restaurant_outlined,
                      label: "Food &\nEssentials",
                      color: Color(0xFFFFF8E1),
                      iconColor: Color(0xFFFFA000)),
                  _QuickCard(
                      icon: Icons.health_and_safety_outlined,
                      label: "Health &\nWellness",
                      color: Color(0xFFFFEBEE),
                      iconColor: Color(0xFFE53935)),
                  _QuickCard(
                      icon: Icons.school_outlined,
                      label: "Education\n& Training",
                      color: Color(0xFFF3E5F5),
                      iconColor: Color(0xFF8E24AA)),
                  _QuickCard(
                      icon: Icons.gavel_outlined,
                      label: "Legal\nSupport",
                      color: Color(0xFFE8EAF6),
                      iconColor: Color(0xFF3949AB)),
                ],
              ),

              const SizedBox(height: 24),

              // ── Latest Updates ───────────────────────────────────────────────
              const Text(
                "Latest Updates",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _purple),
              ),
              const SizedBox(height: 12),

              _UpdateCard(
                icon: Icons.campaign_outlined,
                title: "New Benefits Available",
                subtitle:
                    "Check the latest financial aid programs for solo parents.",
                time: "Today",
                iconColor: _purple,
              ),
              const SizedBox(height: 10),
              _UpdateCard(
                icon: Icons.event_outlined,
                title: "Upcoming Community Event",
                subtitle:
                    "Solo Parent Support Circle — this Saturday, 9AM.",
                time: "2 days",
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 10),
              _UpdateCard(
                icon: Icons.work_outline_rounded,
                title: "5 New Job Openings",
                subtitle:
                    "Remote and flexible jobs posted near your area.",
                time: "3 days",
                iconColor: const Color(0xFFFFA000),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Access Card ──────────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final Color    iconColor;

  static const _purple = Color(0xFF7C6EE6);

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD5C9F5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Update Card ────────────────────────────────────────────────────────────────
class _UpdateCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final String   time;
  final Color    iconColor;

  static const _purpleLight  = Color(0xFFF3F0FF);
  static const _purpleMuted  = Color(0xFFA89CC8);
  static const _purpleBorder = Color(0xFFD5C9F5);

  const _UpdateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purpleBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _purpleMuted,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: const TextStyle(
                  fontSize: 10, color: _purpleMuted)),
        ],
      ),
    );
  }
}
