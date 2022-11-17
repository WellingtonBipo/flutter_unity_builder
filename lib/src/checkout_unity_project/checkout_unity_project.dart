import 'dart:io';

import 'package:flutter_unity_builder/src/pubspec_info/pubspec_info.dart';
import 'package:path/path.dart' as p;

import '../scripts_runner/scripts_runner.dart';

class CheckoutUnityProject extends ScriptsRunner {
  final PubspecInfo pubspecInfo;

  CheckoutUnityProject({
    required this.pubspecInfo,
  }) : super(
          name: 'Checkout Unity Repository',
          scripts: [],
          args: [],
        );

  @override
  List<Script> get scripts => [
        checkIfNeedCheckout,
        checkoutRepository,
      ];

  Directory get repoFolder {
    final dir = p.dirname(pubspecInfo.pubspecFilePath);
    final path = p.join(dir, pubspecInfo.unityProject.repoLocalPath);
    return Directory(path);
  }

  Script get checkIfNeedCheckout => Script(
        name: 'Check if need checkout project',
        doScript: (options) async {
          if (!await repoFolder.exists()) {
            await repoFolder.create(recursive: true);
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

          if (currentVersion == pubspecInfo.unityProject.git.ref) {
            options.shortMessage = 'Unity project is up to date';
            options.finishScripts();
          }
        },
      );

  Script get checkoutRepository => Script(
        name: 'Checkout repository',
        doScript: (options) async {
          if (!await repoFolder.exists()) {
            await repoFolder.create(recursive: true);
          }

          final shellUnityProjectDir =
              options.shell.cd(p.absolute(repoFolder.path));
          await shellUnityProjectDir.run('git init');
          final remoteResult = await shellUnityProjectDir.run('git remote');

          final idxRemote = remoteResult
              .indexWhere((e) => e.stdout.toString().trim() == 'origin');

          final projectRemoteUrl = pubspecInfo.unityProject.git.url;
          if (idxRemote == -1) {
            await shellUnityProjectDir
                .run('git remote add origin $projectRemoteUrl');
          } else {
            await shellUnityProjectDir
                .run('git remote set-url origin $projectRemoteUrl');
          }

          await shellUnityProjectDir.run('git fetch');
          await shellUnityProjectDir
              .run('git checkout ${pubspecInfo.unityProject.git.ref} --force');
        },
      );
}
