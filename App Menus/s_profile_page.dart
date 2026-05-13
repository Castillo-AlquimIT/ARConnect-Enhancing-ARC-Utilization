import 'package:flutter/material.dart';

class SProfilePage extends StatelessWidget {
  const SProfilePage({super.key, required String userName, required int userId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
