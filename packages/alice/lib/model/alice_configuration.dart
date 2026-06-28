import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_memory_storage.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AliceConfiguration with EquatableMixin {
  /// Default max calls count used in default memory storage.
  static const _defaultMaxCalls = 1000;

  /// Default max logs count.
  static const _defaultMaxLogs = 1000;

  /// Directionality of app. Directionality of the app will be used if set to
  /// null. Default value is null.
  final TextDirection? directionality;

  /// Navigator key used to open inspector. Default value is null.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Storage where calls will be saved. The default storage is memory storage.
  final AliceStorage aliceStorage;

  /// Logger instance.
  final AliceLogger aliceLogger;

  AliceConfiguration({
    this.directionality,
    GlobalKey<NavigatorState>? navigatorKey,
    AliceStorage? storage,
    AliceLogger? logger,
  }) : aliceStorage =
           storage ?? AliceMemoryStorage(maxCallsCount: _defaultMaxCalls),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       aliceLogger = logger ?? AliceLogger(maximumSize: _defaultMaxLogs);

  AliceConfiguration copyWith({
    GlobalKey<NavigatorState>? navigatorKey,
    TextDirection? directionality,
    AliceStorage? aliceStorage,
    AliceLogger? aliceLogger,
  }) => AliceConfiguration(
    directionality: directionality ?? this.directionality,
    navigatorKey: navigatorKey ?? this.navigatorKey,
    storage: aliceStorage ?? this.aliceStorage,
    logger: aliceLogger ?? this.aliceLogger,
  );

  @override
  List<Object?> get props => [
    directionality,
    navigatorKey,
    aliceStorage,
    aliceLogger,
  ];
}
