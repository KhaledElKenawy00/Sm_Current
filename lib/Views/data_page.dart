import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/Views/historey_data.dart';
import 'package:flutter_sqlite_auth_app/Views/signal_curve.dart';
import 'package:flutter_sqlite_auth_app/provider/stm32_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stmProvider = Provider.of<STM32Provider>(context);

    Map<String, dynamic> parsedData = {};
    try {
      parsedData = jsonDecode(stmProvider.latestData);
    } catch (e) {
      // بيانات غير صالحة، نسيب parsedData فاضي
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const FullDataPage(),
                ),
              );
            },
            icon: Icon(Icons.shape_line_outlined)),
        title: const Text('STM32 Real-time Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Show Signal Curve',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SignalPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              /// ✅ الجزء الأول (النص العلوي)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: parsedData.isEmpty
                      ? const Center(
                          child: Text(
                            "Waiting for valid JSON data...",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: parsedData.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.data_object,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${entry.key}: ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${entry.value}",
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
