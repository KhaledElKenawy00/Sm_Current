import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sqlite_auth_app/provider/stm32_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class SignalPage extends StatefulWidget {
  const SignalPage({super.key});

  @override
  State<SignalPage> createState() => _SignalPageState();
}

class _SignalPageState extends State<SignalPage> {
  static const double displayWindow = 100; // عرض النافذة الزمنية للرسم

  @override
  Widget build(BuildContext context) {
    final stmProvider = Provider.of<STM32Provider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Static Signal Curve')),
      body: Center(
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 4096,
              minX: 0,
              maxX: displayWindow, // نطاق ثابت لمحور X
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    stmProvider.signalHistory.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      stmProvider.signalHistory[index],
                    ),
                  )
                      .where((spot) => spot.x >= 0 && spot.x <= displayWindow)
                      .toList(),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.blue,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
