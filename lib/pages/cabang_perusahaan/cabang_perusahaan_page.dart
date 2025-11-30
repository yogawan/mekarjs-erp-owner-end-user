import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CabangPerusahaanPage extends StatefulWidget {
  const CabangPerusahaanPage({super.key});

  @override
  State<CabangPerusahaanPage> createState() => _CabangPerusahaanPageState();
}

class _CabangPerusahaanPageState extends State<CabangPerusahaanPage> {
  bool isLoading = true;
  List<dynamic> branches = [];

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("Token tidak ditemukan!");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/branch",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      setState(() {
        branches = response.data["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error Fetch Branch: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Tidak bisa membuka maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cabang Perusahaan")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final item = branches[index];

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
                        Text(
                          item["namaCabang"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Kode: ${item["kodeCabang"]}"),
                        const SizedBox(height: 6),
                        Text("Alamat: ${item["alamat"]}"),
                        const SizedBox(height: 6),
                        Text("Kontak: ${item["kontak"]}"),
                        const SizedBox(height: 12),

                        // Tombol buka maps
                        ElevatedButton(
                          onPressed: () => openMaps(item["googleMapsLink"]),
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
