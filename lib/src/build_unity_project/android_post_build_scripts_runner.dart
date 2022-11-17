import 'package:flutter_unity_builder/src/pubspec_info/pubspec_info.dart';
// import 'package:path/path.dart' as p;

import '../scripts_runner/scripts_runner.dart';

class AndroidPostBuildScriptsRunner extends ScriptsRunner {
  final PubspecInfo pubspecInfo;

  AndroidPostBuildScriptsRunner({
    required this.pubspecInfo,
  }) : super(
          name: 'Android post build changes',
          scripts: [],
          args: [],
        );

  @override
  List<Script> get scripts => [
        // _organizingUnityLibraryFolder,
        // _setupProjectBuildGradle,
        // _setupSrcMainAndroidManifest,
      ];

  // late final _buildPath = p.join('android', pubspecInfo.buildLocation);

  ///
  /// Changes the unity library library folder to the right layout.
  ///
  // Script get _organizingUnityLibraryFolder => Script(
  //       name: 'Organizing Unity library folder',
  //       doScript: (_) async {
  //         if (!Directory(p.join(_buildPath, 'unityLibrary')).existsSync()) {
  //           return;
  //         }

  //         stdout.writeln('Organizing files on unityLibrary folder...');

  //         await deleteFilesOrDirs([
  //           p.join(_buildPath, 'build.gradle'),
  //           p.join(_buildPath, 'settings.gradle'),
  //           p.join(_buildPath, 'local.properties'),
  //         ], ((path) => stdout.writeln('   Deleting file $path')));

  //         await copyFilesOrDirs(p.join(_buildPath, 'launcher/src/main/res'),
  //             p.join(_buildPath, 'src/main/res'),
  //             print: (origin, dest) =>
  //                 stdout.writeln('   Coping file $origin to $dest'));

  //         await copyFilesOrDirs(p.join(_buildPath, 'unityLibrary'), _buildPath,
  //             recursive: true,
  //             print: (origin, dest) =>
  //                 stdout.writeln('   Coping file $origin to $dest'));

  //         await deleteFilesOrDirs([
  //           p.join(_buildPath, 'launcher'),
  //           p.join(_buildPath, 'unityLibrary'),
  //         ], ((path) => stdout.writeln('   Deleting file $path')));
  //       },
  //     );

  ///
  /// Changes the build gradle on unity library.
  ///
  // Script get _setupProjectBuildGradle => Script(
  //       name: 'Setup project build gradle',
  //       doScript: (_) async {
  //         stdout.writeln('Setting up project build.gradle...');
  //         modifyFileReplacingSync(
  //           p.join(_buildPath, 'build.gradle'),
  //           {
  //             'com.android.application': 'com.android.library',
  //             'bundle {': 'splits {',
  //             'enableSplit = false': 'enable false',
  //             'enableSplit = true': 'enable true',
  //             '''implementation fileTree(dir: 'libs', include: ['*.jar'])''':
  //                 'implementation(name: \'unity-classes\', ext:\'jar\')',
  //             RegExp(r"\n.*applicationId '.+'.*\n"): '\n',
  //           },
  //         );
  //       },
  //     );

  ///
  /// Changes the android manifest on unity library to remove activity conde block.
  ///
  // Script get _setupSrcMainAndroidManifest => Script(
  //       name: 'Setup source main Android manifest',
  //       doScript: (_) async {
  //         stdout.writeln('Setting up src/main/AndroidManifest.xml...');
  //         modifyFileReplacingSync(
  //           p.join(_buildPath, 'src/main/AndroidManifest.xml'),
  //           {
  //             RegExp(r'<application.*>'): '<application>',
  //             RegExp(r'<activity.*>(\s|\S)+?</activity>'): '',
  //           },
  //         );
  //       },
  //     );
}

// class AndroidPostBuildScriptsRunner {