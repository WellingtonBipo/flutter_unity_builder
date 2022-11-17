import 'dart:io';

import 'package:process_run/shell.dart';

import 'script_result.dart';

abstract class Script {
  Script._({required this.name});

  final String name;

  factory Script({
    required String name,
    required Future<void> Function(ScriptOptions) doScript,
    Future<Object> Function(Object)? parseError,
    Future<Map<String, String>?> Function(List<String> args)?
        getArgsOrNullIfNotFound,
  }) = ScriptImpl;
}

class ScriptImpl extends Script {
  final Future<void> Function(ScriptOptions) doScript;
  final Future<Object> Function(Object) parseError;
  final Future<Map<String, String>?> Function(List<String> args)
      getArgsOrNullIfNotFound;
  Map<String, String>? parsedArgs;
  bool printResults = false;

  ScriptImpl({
    required String name,
    required this.doScript,
    Future<Object> Function(Object)? parseError,
    Future<Map<String, String>?> Function(List<String> args)?
        getArgsOrNullIfNotFound,
  })  : parseError = parseError ?? ((e) async => e),
        getArgsOrNullIfNotFound =
            getArgsOrNullIfNotFound ?? ((_) async => <String, String>{}),
        super._(name: name);

  Future<String?> getArgsOrReturnError(List<String> args) async {
    parsedArgs = await getArgsOrNullIfNotFound(args);
    if (parsedArgs == null) return 'ERROR: args not found for script "$name"';
    return null;
  }

  Future<ScriptResult> runScript(ScriptOptions options) async {
    if (printResults) stdout.writeln('===> Script "$name" initiated');
    final start = DateTime.now();
    final print = printResults;
    try {
      await doScript(options);
      if (print) stdout.writeln('===> Script "$name" finished with success');
      return ScriptResult.fromSuccess(
          name, start, options.shortMessage, options.subResults);
    } catch (e, stk) {
      Object parsedError = await parseError(e);
      parsedError = _parseIfShellException(parsedError);
      if (print) stdout.writeln('===> Script "$name" finished with failure');
      return ScriptResult.fromFailure(name, start, options.shortMessage,
          options.subResults, parsedError, stk);
    }
  }

  Object _parseIfShellException(Object e) {
    if (e is! ShellException ||
        e.result == null ||
        e.result!.errLines.isEmpty) {
      return e;
    }
    return e.result!.errLines.first;
  }
}

class ScriptOptions {
  final Shell shell;
  final Map<String, String> parsedArgs;
  final void Function() finishScripts;
  String? shortMessage;
  final List<ScriptResult> subResults = [];

  ScriptOptions({
    required this.shell,
    required this.parsedArgs,
    required this.finishScripts,
    this.shortMessage,
  });
}
