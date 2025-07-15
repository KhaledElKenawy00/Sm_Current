import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/Views/emg_curve.dart';
import 'package:flutter_sqlite_auth_app/Views/signal_curve.dart';
import 'package:flutter_sqlite_auth_app/provider/stm1_provider.dart';
import 'package:flutter_sqlite_auth_app/provider/stm2_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stm1 = Provider.of<STM1Provider>(context);
    final stm2 = Provider.of<STM2Provider>(context);

    Map<String, dynamic> parsedSTM2 = {};
    try {
      parsedSTM2 = jsonDecode(stm2.latestData);
    } catch (_) {}

    final emgData = [
      {
        "Parameter": "EMG 1",
        "Value":
            stm1.emg1History.isEmpty ? "0" : stm1.emg1History.last.toString()
      },
      {
        "Parameter": "EMG 2",
        "Value":
            stm1.emg2History.isEmpty ? "0" : stm1.emg2History.last.toString()
      },
      {
        "Parameter": "EMG 3",
        "Value":
            stm1.emg3History.isEmpty ? "0" : stm1.emg3History.last.toString()
      },
    ];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.show_chart),
          tooltip: 'Show Signal Curve',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignalCurve()),
            );
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Show EMG Curve',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmgCurve()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Half - EMG Table (STM1)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildEmgTable(emgData),
            ),
          ),

          // Right Half - STM2 Data Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildJsonTable(parsedSTM2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmgTable(List<Map<String, dynamic>> emgData) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "EMG Latest Values (STM1)",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          DataTable(
            columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Value')),
            ],
            rows: emgData
                .map(
                  (data) => DataRow(
                    cells: [
                      DataCell(Text(data['Parameter'].toString())),
                      DataCell(Text(data['Value'].toString())),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildJsonTable(Map<String, dynamic> stm2Data) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "STM2 JSON Data (Signal & Features)",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: stm2Data.isEmpty
                ? const Center(child: Text("Waiting for STM2 Data..."))
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Parameter')),
                        DataColumn(label: Text('Value')),
                      ],
                      rows: stm2Data.entries
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.key)),
                                DataCell(Text(entry.value.toString())),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
