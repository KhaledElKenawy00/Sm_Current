// stm2_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';

class STM2Provider with ChangeNotifier {
  SerialPort? _port;
  Timer? _pollingTimer;

  List<double> signalHistory = [];
  final int maxPoints = 100;
  int signalValue = 0;
  String latestData = 'Waiting for STM2 data...';

  final DatabaseService _dbService = DatabaseService();
  String _buffer = '';

  void _processData(String jsonString) async {
    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic> &&
          jsonMap.containsKey('Signal_Value')) {
        signalValue = jsonMap['Signal_Value'];
        signalHistory.add(signalValue.toDouble());

        if (signalHistory.length > maxPoints) signalHistory.removeAt(0);

        latestData = jsonString;
        notifyListeners();

        await _dbService.insertReadingSTM2(jsonMap);
      }
    } catch (_) {}
  }

  void startListening() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.length < 2) return;

    _port = SerialPort(ports[1])
      ..BaudRate = 115200
      ..StopBits = 2
      ..ByteSize = 8
      ..Parity = 0;

    if (!_port!.isOpened) _port!.open();
    if (!_port!.isOpened) return;

    _pollingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
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
