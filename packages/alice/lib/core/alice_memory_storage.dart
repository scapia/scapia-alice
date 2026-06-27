import 'dart:async';

import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:collection/collection.dart';

class AliceMemoryStorage implements AliceStorage {
  AliceMemoryStorage({required this.maxCallsCount})
      : assert(maxCallsCount > 0, 'Max calls count should be greater than 0');

  @override
  final int maxCallsCount;

  final List<AliceHttpCall> _calls = [];
  final _controller = StreamController<List<AliceHttpCall>>.broadcast();

  @override
  Stream<List<AliceHttpCall>> get callsStream => _controller.stream;

  @override
  List<AliceHttpCall> getCalls() => _calls;

  void _notify() => _controller.add(List.of(_calls));

  @override
  AliceStats getStats() {
    return (
      total: _calls.length,
      successes: _calls
          .where((c) => (c.response?.status.gte(200) ?? false) && (c.response?.status.lt(300) ?? false))
          .length,
      redirects: _calls
          .where((c) => (c.response?.status.gte(300) ?? false) && (c.response?.status.lt(400) ?? false))
          .length,
      errors: _calls
          .where((c) =>
              ((c.response?.status.gte(400) ?? false) && (c.response?.status.lt(600) ?? false)) ||
              const [-1, 0].contains(c.response?.status))
          .length,
      loading: _calls.where((c) => c.loading).length,
    );
  }

  @override
  void addCall(AliceHttpCall call) {
    if (_calls.length >= maxCallsCount) _calls.removeAt(0);
    _calls.add(call);
    _notify();
  }

  @override
  void addError(AliceHttpError error, int requestId) {
    final call = selectCall(requestId);
    if (call == null) return AliceUtils.log('Selected call is null');
    call.error = error;
    _notify();
  }

  @override
  void addResponse(AliceHttpResponse response, int requestId) {
    final call = selectCall(requestId);
    if (call == null) return AliceUtils.log('Selected call is null');
    call
      ..loading = false
      ..response = response
      ..duration = response.time.millisecondsSinceEpoch -
          (call.request?.time.millisecondsSinceEpoch ?? 0);
    _notify();
  }

  @override
  void removeCalls() {
    _calls.clear();
    _notify();
  }

  @override
  AliceHttpCall? selectCall(int requestId) =>
      _calls.firstWhereOrNull((c) => c.id == requestId);
}
