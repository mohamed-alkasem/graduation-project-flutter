// lib/screens/ogrenci/portfolio_screen.dart
import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portföyüm'),
        backgroundColor: const Color(0xFF3498DB),
      ),
      body: const Center(
        child: Text('Portföy Sayfası - قيد التطوير'),
      ),
    );
  }
}