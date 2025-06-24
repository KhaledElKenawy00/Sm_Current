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

    Map<String, dynamic> parsedData1 = {};
    Map<String, dynamic> parsedData2 = {};

    try {
      parsedData1 = jsonDecode(stmProvider.latestData);
    } catch (e) {}

    try {
      parsedData2 = jsonDecode(stmProvider.latestDataSTM2);
    } catch (e) {}

    final signalValue = stmProvider.signalValue;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 1000 ? 1000.0 : screenWidth * 0.95;

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
            icon: const Icon(Icons.history)),
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
              /// ✅ Top Row with EMG and Signal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// EMG Readings
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🟢 EMG Readings - STM32-2",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          parsedData2.isEmpty
                              ? const Text("Waiting for EMG data...")
                              : SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                        Colors.green.shade100),
                                    columns: const [
                                      DataColumn(
                                          label: Text('Parameter',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Value',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                    rows: parsedData2.entries.map((entry) {
                                      return DataRow(cells: [
                                        DataCell(Text(entry.key)),
                                        DataCell(Text(entry.value.toString())),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  /// Signal Data
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🟠 Signal Data",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.show_chart,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text("Signal Value:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(
                                signalValue.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ✅ STM1 Data takes remaining screen height and scrollable if needed
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🔵 STM32 - 1 Data",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: parsedData1.isEmpty
                            ? const Text("Waiting for valid JSON data...")
                            : SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                      Colors.blue.shade100),
                                  columns: const [
                                    DataColumn(
                                        label: Text('Parameter',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Value',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows: parsedData1.entries.map((entry) {
                                    return DataRow(cells: [
                                      DataCell(Text(entry.key)),
                                      DataCell(Text(entry.value.toString())),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
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
