import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      // Token hilang → suruh login ulang
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    try {
      final dio = Dio();

      final response = await dio.get(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/account/profile",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = response.data["owner"];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil profile: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileData == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada data profile")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Owner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nama: ${profileData!["nama"]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            Text(
              "Email: ${profileData!["email"]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            Text(
              "Status: ${profileData!["isActive"] ? "Aktif" : "Tidak aktif"}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            Text(
              "Dibuat: ${profileData!["createdAt"]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
