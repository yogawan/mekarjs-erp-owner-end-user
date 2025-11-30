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
      backgroundColor: const Color(0xFFEEEEEE),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFFFBB00),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy_outlined),
                  activeIcon: Icon(Icons.smart_toy),
                  label: "Tanya AI",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payments_outlined),
                  activeIcon: Icon(Icons.payments),
                  label: "Keuangan",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_tree_outlined),
                  activeIcon: Icon(Icons.account_tree),
                  label: "Cabang",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.supervisor_account_outlined),
                  activeIcon: Icon(Icons.supervisor_account),
                  label: "Kepala Cabang",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
