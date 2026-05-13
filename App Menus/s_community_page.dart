import 'package:flutter/material.dart';

class SCommunityPage extends StatelessWidget {
  const SCommunityPage({super.key, required int userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: const Center(
        child: Text('Community Page'),
      ),
    );
  }
}
