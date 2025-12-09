import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Cabang Perusahaan"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, "/tanya-ai");
            },
            backgroundColor: const Color(0xFFFFBB00),
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.messageCircle),
            label: const Text(
              "Tanya AI",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, "/create-cabang-perusahaan");
              if (result == true) {
                fetchBranches(); // Refresh list jika berhasil tambah
              }
            },
            backgroundColor: const Color(0xFFFFBB00),
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.plus),
            label: const Text(
              "Cabang Baru",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFBB00)),
            )
          : branches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.store,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Tidak ada data cabang",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFFBB00),
                  onRefresh: fetchBranches,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: branches.length,
                    itemBuilder: (context, index) {
                      final item = branches[index];
                      return _buildBranchCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildBranchCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/detail-cabang-perusahaan",
          arguments: item["_id"],
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFBB00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    LucideIcons.store,
                    color: Color(0xFFFFBB00),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      const SizedBox(height: 4),
                      Text(
                        "Kode: ${item["kodeCabang"]}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(LucideIcons.mapPin, item["alamat"]),
            const SizedBox(height: 8),
            _buildInfoItem(LucideIcons.phone, item["kontak"]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => openMaps(item["googleMapsLink"]),
                icon: const Icon(LucideIcons.map, size: 20),
                label: const Text("Lihat Lokasi di Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBB00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
