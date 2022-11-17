import 'dart:io';

import 'package:path/path.dart' as p;

import '../pubspec_info/pubspec_info.dart';
import '../scripts_runner/scripts_runner.dart';
import 'android_post_build_scripts_runner.dart';
import 'ios_post_build_scripts_runner.dart';
import 'web_post_build_scripts_runner.dart';

enum BuildPlatform { ios, android, web }

class UnityBuilder extends ScriptsRunner {
  UnityBuilder({
    required this.pubspecInfo,
    required this.buildPlatform,
  }) : super(name: 'Unity builder', scripts: [], args: []);

  final PubspecInfo pubspecInfo;
  final BuildPlatform buildPlatform;

  @override
  List<Script> get scripts => [
        _checkIfHaveToBuild,
        // _changeBuildTarget,
        _build,
        if (_postBuild != null) _postBuild!,
        _copyVersionFromProjectFolderToBuildFolder,
      ];

  final List<String> _firtsCommonArgs = ['-quit', '-batchmode', '-logfile'];

  String get _unityBuildRelativePath =>
      pubspecInfo.buildFolderPath(buildPlatform.name);

  Script get _checkIfHaveToBuild => Script(
        name: 'Check if have to build project to ${buildPlatform.name}',
        doScript: (options) async {
          final Directory buildFolder = Directory(_unityBuildRelativePath);
          if (!await buildFolder.exists()) return;

          final repoFolder = Directory(pubspecInfo.unityProject.repoLocalPath);
          if (!await repoFolder.exists()) {
            throw Exception('$repoFolder dir doesn\'t exist');
          }

          final versionBuildFile = File(p.join(
              buildFolder.path, pubspecInfo.flutterBuildVersionFileName));
          if (!await versionBuildFile.exists()) {
            options.shortMessage = 'Version file on Build dir doesn\'t exsit';
            return;
          }

          final unityProjectDirShell = options.shell.cd(repoFolder.path);
          final shellResult = await unityProjectDirShell.run('git status');
          final resultLines = shellResult.first.stdout.toString().split('\n');
          if (resultLines.any((e) =>
              e.contains('Changes not staged for commit') ||
              e.contains('not a git repository'))) {
            return;
          }

          final currentVersion = resultLines.first.trim().split(' ').last;
          final versionFromBuild = await versionBuildFile.readAsString();

          if (versionFromBuild.trim() == currentVersion.trim()) {
            options.shortMessage = 'Unity Build is up to date';
            options.finishScripts();
          }
        },
      );

  // Script get _changeBuildTarget {
  //   const logName = 'change_target';
  //   return Script(
  //     name: 'Change target to build project to ${buildPlatform.name}',
  //     parseError: (e) => _errorFromLogFile(e, logName),
  //     doScript: (options) async {
  //       await options.shell.runExecutableArguments(
  //         pubspecInfo.unityExecutablePath,
  //         [
  //           ..._firtsCommonArgs,
  //           _logFilePath(logName),
  //           '-buildTarget',
  //           buildPlatform.name,
  //         ],
  //       );
  //     },
  //   );
  // }

  Script get _build {
    const logName = 'build';
    return Script(
      name: 'Build to Unity project to ${buildPlatform.name}',
      parseError: (e) => _errorFromLogFile(e, logName),
      doScript: (options) async {
        final projectPath = p.join(
          p.dirname(pubspecInfo.pubspecFilePath),
          pubspecInfo.unityProject.repoLocalPath,
          pubspecInfo.unityProject.git.projectFoler,
        );

        String buildMethodName;
        switch (buildPlatform) {
          case BuildPlatform.ios:
            buildMethodName = 'DoBuildIOSRelease';
            break;
          case BuildPlatform.android:
            buildMethodName = 'DoBuildAndroidLibraryRelease';
            break;
          case BuildPlatform.web:
            buildMethodName = 'DoBuildWebGL';
            break;
        }

        await options.shell.runExecutableArguments(
          pubspecInfo.unityExecutablePath,
          [
            ..._firtsCommonArgs,
            _logFilePath(logName),
            '-projectPath',
            p.absolute(projectPath),
            '-executeMethod',
            'FlutterUnityIntegration.Editor.Build.$buildMethodName',
            // p.absolute(_unityBuildRelativePath),
          ],
        );
      },
    );
  }

  Script? get _postBuild {
    switch (buildPlatform) {
      case BuildPlatform.ios:
        return IosPostBuildScriptsRunner(pubspecInfo: pubspecInfo);
      case BuildPlatform.android:
        return AndroidPostBuildScriptsRunner(pubspecInfo: pubspecInfo);
      case BuildPlatform.web:
        // return WebPostBuildScriptsRunner(pubspecInfo: pubspecInfo);
        return null;
    }
  }

  Script get _copyVersionFromProjectFolderToBuildFolder => Script(
        name: 'Copy version from project folder to build folder',
        doScript: (options) async {
          final versionFilePathOnBuildFolder = File(p.join(
              _unityBuildRelativePath,
              pubspecInfo.flutterBuildVersionFileName));

          await versionFilePathOnBuildFolder
              .writeAsString(pubspecInfo.unityProject.git.ref);
        },
      );

  String _logFilePath(String logName) => p.absolute(
        p.dirname(pubspecInfo.pubspecFilePath),
        buildPlatform.name,
        'logs_unity_build',
        '$logName.log',
      );

  Future<Object> _errorFromLogFile(Object e, String logName) async {
    final filePath = _logFilePath(logName);
    final logFile = File(filePath);
    if (!logFile.existsSync()) return 'Not found log file';
    final logTextLines = logFile.readAsLinesSync();
    final errors = logTextLines
        .where((e) => e.toLowerCase().contains('error'))
        .map((e) => '${e.trim()}\n')
        .join();
    return 'Errors found on Log File ($filePath):\n$errors';
  }
}
