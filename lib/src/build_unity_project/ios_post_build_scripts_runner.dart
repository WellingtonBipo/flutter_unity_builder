import 'dart:io';

import 'package:flutter_unity_builder/src/pubspec_info/pubspec_info.dart';
import 'package:path/path.dart' as p;

import '../scripts_runner/scripts_runner.dart';
import '../utils/files_funcs.dart';

class IosPostBuildScriptsRunner extends ScriptsRunner {
  final PubspecInfo pubspecInfo;
  IosPostBuildScriptsRunner({
    required this.pubspecInfo,
  }) : super(
          name: 'IOS post build changes',
          scripts: [],
          args: [],
        );

  @override
  List<Script> get scripts => [
        // _setupUnityPlayerUtilsFile,
        _setupSkipInstall,
      ];

  ///
  /// Changes the problem when first open scarf, the screen opens blank.
  ///
  // final _setupUnityPlayerUtilsFile = Script(
  //   name: 'Setup Unity player utils file',
  //   doScript: (_) async {
  //     const path =
  //         './ios/.symlinks/plugins/flutter_unity_widget/ios/Classes/UnityPlayerUtils.swift';
  //     stdout.writeln('   Setting up UnityPlayerUtils.swift ($path)');

  //     final file = File(path);
  //     if (!file.existsSync()) {
  //       stdout.writeln('      File not exist! ($path)');
  //       return;
  //     }

  //     final fileTextSplited = file.readAsStringSync().split('\n');
  //     final indexStart =
  //         fileTextSplited.indexWhere((e) => e.contains('func createPlayer('));
  //     final indexEnd = fileTextSplited
  //         .getRange(indexStart, fileTextSplited.length - 1)
  //         .toList()
  //         .indexWhere((e) => e == '    }');

  //     const newCode =
  //         '''    func createPlayer(completed: @escaping (_ view: UIView?) -> Void) {
  //       if unityIsInitiallized() && _isUnityReady {
  //           completed(controller?.rootView)
  //           return
  //       }

  //       DispatchQueue.main.async {
  //           // Always keep Flutter window on top
  //           let flutterLevel = UIWindow.Level.normal.rawValue + 1.0
  //           UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level(flutterLevel)

  //           self.initUnity()
  //           self._isUnityReady = true
  //           completed(controller?.rootView)
  //           self.listenAppState()
  //       }
  //   }''';

  //     fileTextSplited
  //         .replaceRange(indexStart, indexStart + indexEnd + 1, [newCode]);
  //     file.writeAsStringSync(fileTextSplited.join('\n'));
  //   },
  // );

  ///
  /// Changes the problem when deploying (archiving), generate a generic
  /// file insted of mobile file.
  ///
  late final _setupSkipInstall = Script(
    name: 'Setup skip install to yes',
    doScript: (_) async {
      final filePath = p.join(pubspecInfo.buildFolderPath('ios'),
          'Unity-iPhone.xcodeproj/project.pbxproj');
      stdout.writeln('   Setting up $filePath');
      modifyFileReplacingSync(
        filePath,
        {'SKIP_INSTALL = NO': 'SKIP_INSTALL = YES'},
      );
    },
  );
}
