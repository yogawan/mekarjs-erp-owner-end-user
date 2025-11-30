import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateCabangPerusahaanPage extends StatefulWidget {
  const CreateCabangPerusahaanPage({super.key});

  @override
  State<CreateCabangPerusahaanPage> createState() => _CreateCabangPerusahaanPageState();
}

class _CreateCabangPerusahaanPageState extends State<CreateCabangPerusahaanPage> {
  final TextEditingController namaCabangController = TextEditingController();
  final TextEditingController kodeCabangController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController kontakController = TextEditingController();
  final TextEditingController googleMapsLinkController = TextEditingController();

  bool isLoading = false;

  Future<void> createCabang() async {
    if (namaCabangController.text.trim().isEmpty ||
        kodeCabangController.text.trim().isEmpty ||
        alamatController.text.trim().isEmpty ||
        kontakController.text.trim().isEmpty ||
        googleMapsLinkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token tidak ditemukan. Silakan login kembali.")),
        );
        return;
      }

      final dio = Dio();

      final response = await dio.post(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/branch",
        data: {
          "namaCabang": namaCabangController.text.trim(),
          "kodeCabang": kodeCabangController.text.trim(),
          "alamat": alamatController.text.trim(),
          "kontak": kontakController.text.trim(),
          "googleMapsLink": googleMapsLinkController.text.trim(),
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cabang berhasil ditambahkan")),
        );
        Navigator.pop(context, true); // Return true untuk refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan cabang: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Tambah Cabang"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Cabang Perusahaan Baru",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nama Cabang",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaCabangController,
              decoration: InputDecoration(
                hintText: "Masukan nama cabang",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Kode Cabang",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: kodeCabangController,
              decoration: InputDecoration(
                hintText: "Masukan kode cabang",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Alamat",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: alamatController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukan alamat lengkap",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Kontak",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: kontakController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Masukan nomor kontak",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Link Google Maps",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: googleMapsLinkController,
              decoration: InputDecoration(
                hintText: "Masukan link Google Maps",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : createCabang,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(LucideIcons.plus, size: 20),
                label: const Text(
                  "Tambah Cabang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaCabangController.dispose();
    kodeCabangController.dispose();
    alamatController.dispose();
    kontakController.dispose();
    googleMapsLinkController.dispose();
    super.dispose();
  }
}