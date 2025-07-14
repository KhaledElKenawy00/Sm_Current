import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sqlite_auth_app/provider/stm32_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class SignalPage extends StatelessWidget {
  const SignalPage({super.key});

  static const double displayWindow = 100;

  Widget _buildChart(List<double> data, Color color, String label) {
    final displayData = data.length > displayWindow
        ? data.sublist(data.length - displayWindow.toInt())
        : data;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 4096,
                  minX: 0,
                  maxX: displayWindow,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[300], strokeWidth: 0.5),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.grey[300], strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 1024),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 10),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        displayData.length,
                        (index) => FlSpot(index.toDouble(), displayData[index]),
                      ),
                      isCurved: true,
                      barWidth: 2,
                      color: color,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
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
      appBar: AppBar(
        title: const Text('Signal & EMG Curves'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildChart(
                stmProvider.signalHistorySTM2, Colors.purple, "Signal STM2"),
            _buildChart(stmProvider.emg1History, Colors.red, "EMG 1"),
            _buildChart(stmProvider.emg2History, Colors.green, "EMG 2"),
            _buildChart(stmProvider.emg3History, Colors.orange, "EMG 3"),
          ],
        ),
      ),
    );
  }
}
