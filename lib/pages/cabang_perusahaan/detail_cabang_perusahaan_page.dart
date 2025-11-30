import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DetailCabangPerusahaanPage extends StatefulWidget {
  const DetailCabangPerusahaanPage({super.key});

  @override
  State<DetailCabangPerusahaanPage> createState() => _DetailCabangPerusahaanPageState();
}

class _DetailCabangPerusahaanPageState extends State<DetailCabangPerusahaanPage> {
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? branchData;
  String? branchId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    branchId = ModalRoute.of(context)!.settings.arguments as String;
    fetchBranchDetail(branchId!);
  }

  Future<void> fetchBranchDetail(String branchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("Token tidak ditemukan!");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/branch/$branchId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        setState(() {
          branchData = response.data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch Branch Detail: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> deleteBranch() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Cabang"),
        content: const Text("Apakah Anda yakin ingin menghapus cabang ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token tidak ditemukan!")),
        );
        return;
      }

      final dio = Dio();

      final response = await dio.delete(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/branch/$branchId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cabang berhasil dihapus")),
        );
        Navigator.pop(context, true); // Return true untuk refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus cabang: $e")),
      );
    }

    setState(() => isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Detail Cabang"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFBB00)),
            )
          : branchData == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFBB00).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.store,
                                color: Color(0xFFFFBB00),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              branchData!["namaCabang"],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFBB00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                branchData!["kodeCabang"],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFBB00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informasi Cabang",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              LucideIcons.mapPin,
                              "Alamat",
                              branchData!["alamat"],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              LucideIcons.phone,
                              "Kontak",
                              branchData!["kontak"],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              LucideIcons.checkCircle,
                              "Status",
                              branchData!["isActive"] ? "Aktif" : "Tidak Aktif",
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              LucideIcons.calendar,
                              "Dibuat",
                              branchData!["createdAt"],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => openMaps(branchData!["googleMapsLink"]),
                          icon: const Icon(LucideIcons.map, size: 20),
                          label: const Text("Lihat Lokasi di Google Maps"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBB00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isDeleting ? null : deleteBranch,
                          icon: isDeleting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFBB00),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(LucideIcons.trash2, size: 20),
                          label: const Text("Hapus Cabang"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFBB00),
                            padding: const EdgeInsets.all(24),
                            side: BorderSide(
                              color: const Color(0xFFFFBB00).withOpacity(0.15),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFBB00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFFFBB00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}