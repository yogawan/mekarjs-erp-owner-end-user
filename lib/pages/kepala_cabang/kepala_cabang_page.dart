import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'M';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Kepala Cabang"),
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
              final result = await Navigator.pushNamed(context, "/create-kepala-cabang");
              if (result == true) {
                fetchManagers(); // Refresh list jika berhasil tambah
              }
            },
            backgroundColor: const Color(0xFFFFBB00),
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.userPlus),
            label: const Text(
              "Kepala Cabang Baru",
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
          : managers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Tidak ada data kepala cabang",
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
                  onRefresh: fetchManagers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: managers.length,
                    itemBuilder: (context, index) {
                      final item = managers[index];
                      final cabang = item["cabangId"];
                      return _buildManagerCard(item, cabang);
                    },
                  ),
                ),
    );
  }

  Widget _buildManagerCard(dynamic manager, dynamic cabang) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          "/detail-kepala-cabang",
          arguments: manager["_id"],
        );
        if (result == true) {
          fetchManagers(); // Refresh list jika ada perubahan
        }
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
          // Manager Info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFFBB00),
                child: Text(
                  _getInitials(manager["nama"]),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager["nama"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mail,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            manager["email"],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Branch Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFBB00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  LucideIcons.store,
                  color: Color(0xFFFFBB00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cabang["namaCabang"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kode: ${cabang["kodeCabang"]}",
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
          const SizedBox(height: 12),
          _buildInfoItem(LucideIcons.mapPin, cabang["alamat"]),
          const SizedBox(height: 8),
          _buildInfoItem(LucideIcons.phone, cabang["kontak"]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openMaps(cabang["googleMapsLink"]),
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
