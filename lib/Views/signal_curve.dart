import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sqlite_auth_app/provider/stm32_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class SignalPage extends StatelessWidget {
  const SignalPage({super.key});

  static const double displayWindow = 100; // ثابت لمحور X

  Widget _buildChart(List<double> data, Color color, String label) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 4096,
                  minX: 0,
                  maxX: displayWindow,
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      )
                          .where(
                              (spot) => spot.x >= 0 && spot.x <= displayWindow)
                          .toList(),
                      isCurved: true,
                      barWidth: 2,
                      color: color,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stmProvider = Provider.of<STM32Provider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Signal & EMG Curves')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildChart(stmProvider.signalHistory, Colors.blue, "Signal"),
            _buildChart(stmProvider.emg1History, Colors.red, "EMG 1"),
            _buildChart(stmProvider.emg2History, Colors.green, "EMG 2"),
            _buildChart(stmProvider.emg3History, Colors.orange, "EMG 3"),
          ],
        ),
      ),
    );
  }
}
