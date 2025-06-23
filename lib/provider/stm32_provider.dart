import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class STM32Provider with ChangeNotifier {
  SerialPort? _port;
  List<double> signalHistory = [];
  final int maxPoints = 100;

  Timer? _pollingTimer;
  String latestData = 'Waiting for data...';
  final List<String> logs = [];
  final DatabaseService _dbService = DatabaseService();
  String _buffer = '';
  int signalValue = 0;

  void startListening() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) {
      print("❌ No serial ports found.");
      return;
    }

    final port = SerialPort(ports.first)
      ..BaudRate = 9600
      ..StopBits = 2
      ..ByteSize = 8
      ..Parity = 0;

    if (!port.isOpened) {
      port.open();
      if (port.isOpened) {
        print("✅ Port opened: ${port.portName}");
      } else {
        print("❌ Failed to open port: ${port.portName}");
        return;
      }
    }

    _port = port;

    _pollingTimer =
        Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      try {
        Uint8List data = await port.readBytes(1024,
            timeout: const Duration(milliseconds: 1));
        if (data.isNotEmpty) {
          final decoded = utf8.decode(data, allowMalformed: true);
          _buffer += decoded;
          _processBuffer();
        }
      } catch (e) {
        print("❌ Read error: $e");
      }
    });
  }

  void _processBuffer() {
    final jsonRegex = RegExp(r'\{[^}]*\}');

    for (final match in jsonRegex.allMatches(_buffer)) {
      final jsonString = match.group(0);
      if (jsonString != null) {
        latestData = jsonString;
        logs.insert(0, jsonString);
        if (logs.length > 100) logs.removeLast();
        notifyListeners();

        _tryParseJson(jsonString);
      }
    }

    final lastMatch = jsonRegex.allMatches(_buffer).lastOrNull;
    if (lastMatch != null) {
      _buffer = _buffer.substring(lastMatch.end);
    }
  }

  void _tryParseJson(String line) {
    try {
      final jsonMap = jsonDecode(line);
      if (jsonMap is Map<String, dynamic>) {
        signalValue = jsonMap['Signal_Value'] ?? 0;

        signalHistory.add(signalValue.toDouble());
        if (signalHistory.length > maxPoints) {
          signalHistory.removeAt(0);
        }

        notifyListeners();
      }
    } catch (e) {
      print("⚠️ JSON parse error: $e");
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _port?.close();
    super.dispose();
  }
}
