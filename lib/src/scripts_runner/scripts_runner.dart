library scripts_runner;

import 'dart:io';

import 'package:process_run/shell.dart';

import 'extensions.dart';
import 'script.dart';
import 'script_result.dart';
import 'utils.dart';

export 'script.dart' show Script;

class ScriptsRunner extends ScriptImpl {
  ScriptsRunner({
    required super.name,
    required this.args,
    required this.scripts,
    bool printResults = true,
    Shell? shell,
  })  : _shell = shell ?? Shell(),
        super(doScript: (options) async {}) {
    super.printResults = printResults;
  }

  final List<String> args;
  final List<Script> scripts;
  final Shell _shell;

  Future<List<ScriptResult>> run([bool throwsIfHasFailure = true]) async {
    final scriptResults = await _run();
    if (printResults) _printAllResults(scriptResults);
    if (scriptResults.any((e) => e is ScriptFailure) && throwsIfHasFailure) {
      throw Exception('Script results has one failure');
    }
    return scriptResults;
  }

  @override
  Future<void> Function(ScriptOptions) get doScript =>
      (ScriptOptions options) async {
        final scriptResults = await _run();
        options.subResults.addAll(scriptResults);
        final firstFailure =
            scriptResults.firstWhereOrNull((e) => e is ScriptFailure);
        if (firstFailure != null) {
          throw 'Script "${firstFailure.name}" failure.';
        }
      };

  Future<List<ScriptResult>> _run() async {
    _checkHasScripts();
    await _getScriptArgs();
    return await _runScripts();
  }

  void _checkHasScripts() {
    if (scripts.isEmpty) {
      if (printResults) printLines(_wrapOnHeader(['ERROR: No scripts found']));
      throw Exception('ERROR: No scripts found');
    }
  }

  Future<void> _getScriptArgs() async {
    for (var script in scripts) {
      final error = await (script as ScriptImpl).getArgsOrReturnError(args);
      if (error == null) continue;
      if (printResults) printLines(_wrapOnHeader([error]));
      throw Exception(error);
    }
  }

  Future<List<ScriptResult>> _runScripts() async {
    final scriptResults = <ScriptResult>[];
    bool continueScripts = true;
    for (final script in scripts) {
      if (!continueScripts) break;
      final options = ScriptOptions(
        shell: _shell,
        parsedArgs: (script as ScriptImpl).parsedArgs ?? {},
        finishScripts: () => continueScripts = false,
      );
      script.printResults = printResults;
      final scriptResult = await script.runScript(options);
      scriptResults.add(scriptResult);
      if (scriptResult.isFailure) break;
    }
    return scriptResults;
  }

  void _printAllResults(List<ScriptResult> scriptResults) {
    Duration totalDuration =
        scriptResults.fold<Duration>(Duration.zero, (p, e) => p + e.duration);

    List<String> result = ['TOTAL DURATION: ${totalDuration.inTimeFormat}', ''];

    result.addAll(scriptResults.map<String>(
        (e) => <String>[e.toString(), ...e.subResultsString].join('\n')));

    result = _wrapOnHeader(result);

    final error = scriptResults.whereType<ScriptFailure>().firstOrNull;
    if (error != null) stdout.writeln('\n${error.scriptFailureFullError}');

    printLines(result);
  }

  List<String> _wrapOnHeader(
    List<String> body,
  ) {
    return [
      '',
      '======= ${name.toUpperCase()} SCRIPTS RESULT =======',
      '',
      ...body,
      '',
      '====== ${name.toUpperCase()} SCRIPTS FINISHED ======',
      '',
    ];
  }
}
