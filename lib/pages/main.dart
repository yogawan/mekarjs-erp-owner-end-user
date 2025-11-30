// lib/pages/main.dart
import 'package:flutter/material.dart';
import '../pages/tanya_ai/tanya_ai_page.dart';
import '../pages/keuangan/keuangan_page.dart';
import '../pages/kepala_cabang/kepala_cabang_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/cabang_perusahaan/cabang_perusahaan_page.dart';

class BNav extends StatefulWidget {
  const BNav({super.key});

  @override
  State<BNav> createState() => _BNavState();
}

class _BNavState extends State<BNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TanyaAiPage(),
    KeuanganPage(),
    CabangPerusahaanPage(),
    KepalaCabangPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: "Tanya AI",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: "Keuangan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            label: "Cabang Perusahaan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            label: "Kepala Cabang",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
