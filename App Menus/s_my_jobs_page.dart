import 'package:flutter/material.dart';

class SMyJobsPage extends StatefulWidget {
  const SMyJobsPage({super.key, required int userId});

  @override
  State<SMyJobsPage> createState() => _SMyJobsPageState();
}

class _SMyJobsPageState extends State<SMyJobsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
      ),
      body: const Center(
        child: Text('My Jobs Page'),
      ),
    );
  }
}
