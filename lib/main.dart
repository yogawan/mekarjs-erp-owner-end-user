// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'pages/main.dart';
import 'pages/tanya_ai/tanya_ai_page.dart';
import 'pages/keuangan/keuangan_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/create_account_page.dart';
import 'pages/splash/splash_page.dart';

// Cabang Perusahaan
import 'pages/cabang_perusahaan/cabang_perusahaan_page.dart';
import 'pages/cabang_perusahaan/create_cabang_perusahaan_page.dart';
import 'pages/cabang_perusahaan/detail_cabang_perusahaan_page.dart';

// Kepala Cabang
import 'pages/kepala_cabang/kepala_cabang_page.dart';
import 'pages/kepala_cabang/create_kepala_cabang_page.dart';
import 'pages/kepala_cabang/detail_kepala_cabang_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      theme: ThemeData(textTheme: GoogleFonts.playfairDisplayTextTheme()),

      routes: {
        '/': (context) => const BNav(),
        '/tanya-ai': (context) => const TanyaAiPage(),
        '/keuangan': (context) => const KeuanganPage(),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountPage(),
        '/splash': (context) => const SplashPage(),

        // Cabang Perusahaan
        '/cabang-perusahaan': (context) => const CabangPerusahaanPage(),
        '/create-cabang-perusahaan': (context) => const CreateCabangPerusahaanPage(),
        '/detail-cabang-perusahaan': (context) => const DetailCabangPerusahaanPage(),

        // Kepala Cabang
        '/kepala-cabang': (context) => const KepalaCabangPage(),
        '/create-kepala-cabang': (context) => const CreateKepalaCabangPage(),
        '/detail-kepala-cabang': (context) => const DetailKepalaCabangPage(),
      },
    );
  }
}
