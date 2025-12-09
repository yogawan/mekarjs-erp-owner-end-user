import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> login() async {
    // Validasi input
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email tidak boleh kosong")),
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak boleh kosong")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = Dio();
      
      const url = "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/account/login";
      final requestData = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      // DEBUG: Print request details
      print("🔵 LOGIN REQUEST");
      print("URL: $url");
      print("Data: $requestData");

      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {"Content-Type": "application/json"},
          validateStatus: (status) => true, // Accept all status codes
        ),
      );

      // DEBUG: Print response
      print("🟢 LOGIN RESPONSE");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data["token"] != null) {
          final token = data["token"] as String;
          final owner = data["owner"] as Map<String, dynamic>;
          final message = data["message"] as String?;

          print("✅ Login Success");
          print("Token: ${token.substring(0, 20)}...");
          print("Owner: ${owner["nama"]}");

          // SIMPAN TOKEN DAN DATA OWNER KE SHARED PREF
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("owner_id", owner["_id"] ?? "");
          await prefs.setString("owner_name", owner["nama"] ?? "");
          await prefs.setString("owner_email", owner["email"] ?? "");
          await prefs.setBool("owner_isActive", owner["isActive"] ?? false);

          print("💾 Data saved to SharedPreferences");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message ?? "Login berhasil")),
            );

            // ⬅️ REDIRECT KE HOME ROUTE "/"
            Navigator.pushReplacementNamed(context, "/");
          }
        } else {
          print("❌ Token not found in response");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Token tidak ditemukan")),
            );
          }
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        if (mounted) {
          String errorMessage = "Login gagal";
          if (response.data != null && response.data["message"] != null) {
            errorMessage = response.data["message"];
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } on DioException catch (e) {
      print("🔴 DioException caught");
      print("Type: ${e.type}");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");
      
      if (mounted) {
        String errorMessage = "Login gagal";
        
        if (e.response?.data != null && e.response?.data["message"] != null) {
          errorMessage = e.response?.data["message"];
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Koneksi timeout";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "Tidak dapat terhubung ke server";
        } else if (e.type == DioExceptionType.unknown) {
          errorMessage = "Error: ${e.message}";
        } else {
          errorMessage = "Login gagal: ${e.message}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e, stackTrace) {
      print("🔴 Unexpected Error");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Masuk dan Mulai Pantau Bisnis Anda",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Masukan email anda",
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: "Masukan password anda",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : login,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(LucideIcons.logIn, size: 20),
                label: const Text(
                  "Login",
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
}
