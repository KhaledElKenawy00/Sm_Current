import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class STM32Provider with ChangeNotifier {
  SerialPort? _port;
  SerialPort? _secondPort;
  Timer? _pollingTimer;
  Timer? _secondPollingTimer;

  List<double> signalHistory = [];
  final int maxPoints = 100;
  int signalValue = 0;

  String latestData = 'Waiting for data...';
  String latestDataSTM2 = 'Waiting for STM32 2 data...';

  final List<String> logs = [];
  final DatabaseService _dbService = DatabaseService();
  String _buffer = '';

  void _processSTMBuffer(String data, String device) async {
    final jsonRegex = RegExp(r'\{[^}]*\}');

    for (final match in jsonRegex.allMatches(data)) {
      final jsonString = match.group(0);
      if (jsonString != null) {
        if (device == 'STM1') {
          latestData = jsonString;
        } else {
          latestDataSTM2 = jsonString;
        }

        logs.insert(0, "$device: $jsonString");
        if (logs.length > 100) logs.removeLast();
        notifyListeners();

        try {
          final jsonMap = jsonDecode(jsonString);
          if (jsonMap is Map<String, dynamic>) {
            if (device == 'STM1') {
              signalValue = jsonMap['Signal_Value'] ?? 0;
              signalHistory.add(signalValue.toDouble());
              if (signalHistory.length > maxPoints) {
                signalHistory.removeAt(0);
              }
              notifyListeners();
            }

            await _dbService.insertReadingUnified(jsonMap, device);
            print("✅ Stored $device Data: $jsonMap");
          }
        } catch (e) {
          print("⚠️ JSON parse error for $device: $e");
        }
      }
    }
  }

  void startSecondSTM32() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.length < 2) {
      print("❌ Less than 2 ports available. Cannot start second STM32.");
      return;
    }

    _secondPort = SerialPort(ports[1])
      ..BaudRate = 115200
      ..StopBits = 2
      ..ByteSize = 8
      ..Parity = 0;

    if (!_secondPort!.isOpened) {
      _secondPort!.open();
      if (_secondPort!.isOpened) {
        print("✅ Second port opened: ${_secondPort!.portName}");
      } else {
        print("❌ Failed to open second port: ${_secondPort!.portName}");
        return;
      }
    }

    _secondPollingTimer =
        Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      try {
        Uint8List data = await _secondPort!
            .readBytes(1024, timeout: const Duration(milliseconds: 1));
        if (data.isNotEmpty) {
          final decoded = utf8.decode(data, allowMalformed: true);
          _processSTMBuffer(decoded, 'STM2');
        }
      } catch (e) {
        print("❌ STM2 Read Error: $e");
      }
    });
  }

  void startListening() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) {
      print("❌ No serial ports found.");
      return;
    }

    _port = SerialPort(ports.first)
      ..BaudRate = 115200
      ..StopBits = 2
      ..ByteSize = 8
      ..Parity = 0;

    if (!_port!.isOpened) {
      _port!.open();
      if (_port!.isOpened) {
        print("✅ Port opened: ${_port!.portName}");
      } else {
        print("❌ Failed to open port: ${_port!.portName}");
        return;
      }
    }

    _pollingTimer =
        Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      try {
        Uint8List data = await _port!
            .readBytes(1024, timeout: const Duration(milliseconds: 1));
        if (data.isNotEmpty) {
          final decoded = utf8.decode(data, allowMalformed: true);
          _buffer += decoded;
          _processMainBuffer();
        }
      } catch (e) {
        print("❌ Read error: $e");
      }
    });
  }

  void _processMainBuffer() {
    final jsonRegex = RegExp(r'\{[^}]*\}');

    for (final match in jsonRegex.allMatches(_buffer)) {
      final jsonString = match.group(0);
      if (jsonString != null) {
        latestData = jsonString;
        logs.insert(0, "STM1: $jsonString");
        if (logs.length > 100) logs.removeLast();
        notifyListeners();

        _processSTMBuffer(jsonString, "STM1");
      }
    }

    final lastMatch = jsonRegex.allMatches(_buffer).lastOrNull;
    if (lastMatch != null) {
      _buffer = _buffer.substring(lastMatch.end);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _secondPollingTimer?.cancel();
    _port?.close();
    _secondPort?.close();
    super.dispose();
  }
}
