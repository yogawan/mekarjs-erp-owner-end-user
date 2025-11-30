import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TanyaAiPage extends StatefulWidget {
  const TanyaAiPage({super.key});

  @override
  State<TanyaAiPage> createState() => _TanyaAiPageState();
}

class _TanyaAiPageState extends State<TanyaAiPage> {
  final TextEditingController _askController = TextEditingController();

  bool isLoading = false;
  String aiResponse = "";

  Future<void> askToAI() async {
    final question = _askController.text.trim();
    if (question.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("TOKEN TIDAK DITEMUKAN!");
        return;
      }

      final dio = Dio();

      final response = await dio.post(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/ai-llm",
        data: {"askToCoreQuarry": question},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      setState(() {
        aiResponse = response.data["responseCoreQuarry"] ?? "Tidak ada jawaban";
        isLoading = false;
      });
    } catch (e) {
      print("Error Tanya AI: $e");
      setState(() {
        aiResponse = "Terjadi kesalahan saat bertanya ke AI.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tanya AI")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _askController,
              decoration: InputDecoration(
                labelText: "Tanyakan sesuatu...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              minLines: 1,
              maxLines: 5,
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: isLoading ? null : askToAI,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Kirim"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(aiResponse, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
