import 'dart:async';
import 'dart:io' show Platform, Process, ProcessResult;

import 'package:alice/model/alice_log.dart';

/// Logger used to handle logs from application.
class AliceLogger {
  /// Maximum logs size. If 0, logs will not be rotated.
  final int maximumSize;

  final List<AliceLog> _logs = [];
  final _controller = StreamController<List<AliceLog>>.broadcast();

  AliceLogger({required this.maximumSize});

  Stream<List<AliceLog>> get logsStream => _controller.stream;

  List<AliceLog> get logs => List.of(_logs);

  void addAll(Iterable<AliceLog> logs) {
    for (final log in logs) {
      add(log);
    }
  }

  void add(AliceLog log) {
    if (maximumSize > 0 && _logs.length >= maximumSize) {
      _logs.removeAt(0);
    }
    _logs.add(log);
    _logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _controller.add(List.of(_logs));
  }

  void clearLogs() {
    _logs.clear();
    _controller.add([]);
  }

  Future<String> getAndroidRawLogs() async {
    if (Platform.isAndroid) {
      final ProcessResult process = await Process.run('logcat', ['-v', 'raw', '-d']);
      return process.stdout as String;
    }
    return '';
  }

  Future<void> clearAndroidRawLogs() async {
    if (Platform.isAndroid) {
      await Process.run('logcat', ['-c']);
    }
  }
}
