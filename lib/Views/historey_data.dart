import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';

class FullDataPage extends StatefulWidget {
  const FullDataPage({super.key});

  @override
  State<FullDataPage> createState() => _FullDataPageState();
}

class _FullDataPageState extends State<FullDataPage> {
  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAllData();
  }

  Future<List<Map<String, dynamic>>> _loadAllData() async {
    final dbService = DatabaseService();
    return await dbService.getAllReadings();
  }

  Widget _buildReadingCard(Map<String, dynamic> reading) {
    final String device = reading['device'] ?? 'Unknown';
    final Color color = device == 'STM1' ? Colors.green : Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⏰ Time: ${reading['timestamp']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("💻 Device: $device", style: TextStyle(color: color)),
          const SizedBox(height: 4),
          Text(reading['json_data']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📂 All Stored Data"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _dataFuture = _loadAllData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.amber.withOpacity(0.2),
            padding: const EdgeInsets.all(8),
            child: const Text(
              "📦 These are stored readings. STM32 connection is not required.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("❌ Error loading data: ${snapshot.error}"),
                  );
                }

                final readings = snapshot.data ?? [];

                if (readings.isEmpty) {
                  return const Center(child: Text("No readings available."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: readings.length,
                  itemBuilder: (context, index) {
                    return _buildReadingCard(readings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
