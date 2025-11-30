import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class KepalaCabangPage extends StatefulWidget {
  const KepalaCabangPage({super.key});

  @override
  State<KepalaCabangPage> createState() => _KepalaCabangPageState();
}

class _KepalaCabangPageState extends State<KepalaCabangPage> {
  bool isLoading = true;
  List<dynamic> managers = [];

  @override
  void initState() {
    super.initState();
    fetchManagers();
  }

  Future<void> fetchManagers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("TOKEN TIDAK ADA!!");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/branch-manager",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      setState(() {
        managers = response.data["managers"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetch branch managers: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kepala Cabang")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: managers.length,
              itemBuilder: (context, index) {
                final item = managers[index];
                final cabang = item["cabangId"];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Manager
                        Text(
                          item["nama"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Email
                        Text("Email: ${item["email"]}"),

                        const Divider(height: 20),

                        // Data cabang
                        Text(
                          cabang["namaCabang"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text("Kode: ${cabang["kodeCabang"]}"),
                        const SizedBox(height: 6),

                        Text("Alamat: ${cabang["alamat"]}"),
                        const SizedBox(height: 6),

                        Text("Kontak: ${cabang["kontak"]}"),
                        const SizedBox(height: 12),

                        ElevatedButton(
                          onPressed: () => openMaps(cabang["googleMapsLink"]),
                          child: const Text("Lihat Lokasi di Google Maps"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
