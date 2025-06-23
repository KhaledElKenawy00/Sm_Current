import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/SQLite/store_data.dart';

class FullDataPage extends StatefulWidget {
  const FullDataPage({super.key});

  @override
  State<FullDataPage> createState() => _FullDataPageState();
}

class _FullDataPageState extends State<FullDataPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _sessions = [];
  Map<int, List<Map<String, dynamic>>> _readingsMap = {}; // مفتاحه session_id
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final sessions = await _dbService.getAllSessions();

    final readingsMap = <int, List<Map<String, dynamic>>>{};
    for (final session in sessions) {
      final readings =
          await _dbService.getReadingsForSession(session['id'] as int);
      readingsMap[session['id'] as int] = readings;
    }

    setState(() {
      _sessions = sessions;
      _readingsMap = readingsMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📂 All Stored Data")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text("No stored sessions yet."))
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final sessionId = session['id'] as int;
                    final sessionDate = session['session_date'] as String;
                    final readings = _readingsMap[sessionId] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📅 Session Date: $sessionDate",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            readings.isEmpty
                                ? const Text("No readings for this session.")
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: readings.length,
                                    itemBuilder: (context, readingIndex) {
                                      final reading = readings[readingIndex];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "⏰ Time: ${reading['timestamp']}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(reading['json_data']),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
