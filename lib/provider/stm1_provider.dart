// stm1_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';

class STM1Provider with ChangeNotifier {
  SerialPort? _port;
  Timer? _pollingTimer;

  List<double> emg1History = [];
  List<double> emg2History = [];
  List<double> emg3History = [];
  final int maxPoints = 100;
  String latestData = 'Waiting for STM1 data...';

  final DatabaseService _dbService = DatabaseService();
  String _buffer = '';

  void _processData(String jsonString) async {
    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic>) {
        if (jsonMap.containsKey('Signal_Value')) {
          jsonMap.remove('Signal_Value'); // تأكد من تجاهل signal
        }

        final emg1 = (jsonMap['EMG1'] ?? 0).toDouble();
        final emg2 = (jsonMap['EMG2'] ?? 0).toDouble();
        final emg3 = (jsonMap['EMG3'] ?? 0).toDouble();

        emg1History.add(emg1);
        emg2History.add(emg2);
        emg3History.add(emg3);

        if (emg1History.length > maxPoints) emg1History.removeAt(0);
        if (emg2History.length > maxPoints) emg2History.removeAt(0);
        if (emg3History.length > maxPoints) emg3History.removeAt(0);

        latestData = jsonString;
        notifyListeners();

        await _dbService.insertReadingSTM1(jsonMap);
      }
    } catch (_) {}
  }

  void startListening() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) return;

    _port = SerialPort(ports.first)
      ..BaudRate = 115200
      ..StopBits = 2
      ..ByteSize = 8
      ..Parity = 0;

    if (!_port!.isOpened) _port!.open();
    if (!_port!.isOpened) return;

    _pollingTimer = Timer.periodic(const Duration(milliseconds: 10), (_) async {
      try {
        Uint8List data = await _port!
            .readBytes(1024, timeout: const Duration(milliseconds: 1));
        if (data.isNotEmpty) {
          final decoded = utf8.decode(data, allowMalformed: true);
          _buffer += decoded;
          final regex = RegExp(r'\{[^}]*\}');
          for (final match in regex.allMatches(_buffer)) {
            _processData(match.group(0)!);
          }
          final last = regex.allMatches(_buffer).lastOrNull;
          if (last != null) _buffer = _buffer.substring(last.end);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _port?.close();
    super.dispose();
  }
}
