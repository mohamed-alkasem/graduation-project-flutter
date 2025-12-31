// lib/screens/ogrenci/projects_screen.dart
import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projelerim'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: const Center(
        child: Text('Projeler Sayfası - قيد التطوير'),
      ),
    );
  }
}