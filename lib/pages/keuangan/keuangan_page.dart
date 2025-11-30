import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  bool isLoading = true;

  String pemasukan = "-";
  String pengeluaran = "-";
  String netProfit = "-";
  String timestamp = "-";

  @override
  void initState() {
    super.initState();
    fetchKeuangan();
  }

  Future<void> fetchKeuangan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("Token tidak ditemukan!");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://mekarjs-erp-core-service.yogawanadityapratama.com/api/owner/finance",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      final data = response.data;

      setState(() {
        pemasukan = data["pemasukan"];
        pengeluaran = data["pengeluaran"];
        netProfit = data["netProfit"];
        timestamp = data["timestamp"];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetch keuangan: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatRupiah(String value) {
    if (value == "-") return value;
    try {
      final number = double.parse(value.replaceAll(RegExp(r'[^0-9.-]'), ''));
      final formatted = number.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return 'Rp $formatted';
    } catch (e) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Keuangan"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFBB00)),
            )
          : RefreshIndicator(
              color: const Color(0xFFFFBB00),
              onRefresh: fetchKeuangan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan Keuangan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Update: $timestamp",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFinanceCard(
                      title: "Pemasukan",
                      amount: _formatRupiah(pemasukan),
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                      backgroundColor: Colors.green.shade50,
                    ),
                    const SizedBox(height: 16),
                    _buildFinanceCard(
                      title: "Pengeluaran",
                      amount: _formatRupiah(pengeluaran),
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                      backgroundColor: Colors.red.shade50,
                    ),
                    const SizedBox(height: 16),
                    _buildFinanceCard(
                      title: "Net Profit",
                      amount: _formatRupiah(netProfit),
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFFFFBB00),
                      backgroundColor: const Color(0xFFFFBB00).withOpacity(0.1),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: const Color(0xFFFFBB00), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: isHighlight ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? const Color(0xFFFFBB00) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
