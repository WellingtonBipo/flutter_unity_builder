import 'extensions.dart';

abstract class ScriptResult {
  final String name;
  final Duration duration;
  final String? shortMessage;
  final List<ScriptResult> subResults;

  ScriptResult({
    required this.name,
    required DateTime start,
    required this.shortMessage,
    required this.subResults,
  }) : duration = DateTime.now().difference(start);

  List<String> get subResultsString {
    final list = <String>[];
    for (var result in subResults) {
      list.addAll(
          [result.toString(), ...result.subResultsString].map((e) => '  $e'));
    }
    return list;
  }

  factory ScriptResult.fromSuccess(
    String name,
    DateTime start,
    String? shortMessage,
    List<ScriptResult> subResults,
  ) =>
      ScriptSuccess._(
        name: name,
        start: start,
        shortMessage: shortMessage,
        subResults: subResults,
      );

  factory ScriptResult.fromFailure(
    String name,
    DateTime start,
    String? shortMessage,
    List<ScriptResult> subResults,
    Object error,
    StackTrace stk,
  ) =>
      ScriptFailure._(
        name: name,
        start: start,
        shortMessage: shortMessage,
        subResults: subResults,
        error: error,
        stackTrace: stk,
      );

  bool get isFailure => this is ScriptFailure;

  @override
  String toString() => '$name: ${duration.inTimeFormat}';
}

class ScriptSuccess extends ScriptResult {
  ScriptSuccess._({
    required super.name,
    required super.start,
    required super.shortMessage,
    required super.subResults,
  });

  @override
  String toString() {
    String endMessage = shortMessage ?? '';
    if (endMessage.isNotEmpty) endMessage = ' => $endMessage';
    return 'SUCCESS => ${super.toString()}$endMessage';
  }
}

class ScriptFailure extends ScriptResult {
  ScriptFailure._({
    required super.name,
    required super.start,
    required super.shortMessage,
    required super.subResults,
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    final localShortMessage = shortMessage ?? '';
    final end = (localShortMessage.isNotEmpty)
        ? localShortMessage
        : ' => ${error.toString().split('\n').first}';
    return 'ERROR   => ${super.toString()} => $end';
  }

  String get scriptFailureFullError => '==========ScriptFailure=========='
      '\n\nScript name: $name'
      '\nDuration:${duration.inTimeFormat}'
      '\nError: $error'
      '\n$stackTrace';
}
