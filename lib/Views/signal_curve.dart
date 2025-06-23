import 'dart:async';
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
  late Timer _timer;
  double _time = 0;
  static const double speedFactor = 10; // كل ما تزودها، الخط يمشي أسرع
  static const double displayWindow = 100; // عرض النافذة الزمنية للرسم

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _time += speedFactor * 0.03; // سرعة التقدم في المحور X
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stmProvider = Provider.of<STM32Provider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Signal Curve (Fast Moving)')),
      body: Center(
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 4096,
              minX: _time - displayWindow,
              maxX: _time,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    stmProvider.signalHistory.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      stmProvider.signalHistory[index],
                    ),
                  )
                      .where((spot) =>
                          spot.x >= _time - displayWindow && spot.x <= _time)
                      .toList(),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
