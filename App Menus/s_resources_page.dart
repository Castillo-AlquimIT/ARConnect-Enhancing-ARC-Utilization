// s_resources.dart
import 'package:flutter/material.dart';

class SResourcesPage extends StatefulWidget {
  final String? initialCategory;
  const SResourcesPage({super.key, this.initialCategory, required int userId});

  @override
  State<SResourcesPage> createState() => _SResourcesPageState();
}

class _SResourcesPageState extends State<SResourcesPage> {
  static const Color _purpleStart = Color(0xFF6C47C9);
  static const Color _purpleEnd = Color(0xFF9B6DF0);
  String _searchQuery = '';
  String? _selectedCategory;
  final List<Map<String, String>> _featured = [
    {
      "title": "Single Parent Financial Aid Programs",
      "subtitle": "Find local financial aid programs for single parents"
    },
    {
      "title": "Affordable Housing Finder",
      "subtitle": "Find local housing assistance and shelter support"
    },
    {
      "title": "Resume Builder Templates",
      "subtitle": "Create a professional resume with easy-to-use tools"
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {"label": "Financial Support", "icon": Icons.attach_money},
    {"label": "Home Assistance", "icon": Icons.home},
    {"label": "Food & Essentials", "icon": Icons.local_grocery_store},
    {"label": "Health & Wellness", "icon": Icons.health_and_safety},
    {"label": "Education & Training", "icon": Icons.school},
    {"label": "Legal Support", "icon": Icons.gavel},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void _onCategoryTap(String label) {
    setState(() => _selectedCategory = label);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category: $label')));
  }

  void _onResourceTap(Map<String, String> resource) {
    // Open resource detail or external link
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(resource['title']!),
        content: Text(resource['subtitle']!),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open resource (placeholder)')));
          }, child: const Text('Open')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController(text: _searchQuery);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_purpleStart, _purpleEnd], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top row: search and bell
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        onSubmitted: (v) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search: $v'))),
                        decoration: InputDecoration(
                          hintText: 'Search Resources',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications (placeholder)'))),
                      icon: const Icon(Icons.notifications, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Browse by Category
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Expanded(child: Text('Browse by Category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _categories.map((c) {
                    final label = c['label'] as String;
                    final icon = c['icon'] as IconData;
                    final selected = label == _selectedCategory;
                    return GestureDetector(
                      onTap: () => _onCategoryTap(label),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: selected ? _purpleStart : Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? _purpleStart : Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Featured Resources header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Expanded(child: Text('Featured Resources', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Featured list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _featured.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _featured[index];
                    return Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _onResourceTap(item),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.bookmark_outline, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(item['subtitle']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _onResourceTap(item),
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation bar (same structure as dashboard)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _purpleStart,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          // Simple placeholder actions; integrate with app navigation
          switch (index) {
            case 0:
              Navigator.pop(context); // go back to dashboard
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nav placeholder')));
          }
        },
      ),
    );
  }
}
