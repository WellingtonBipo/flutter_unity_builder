import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:flutter_unity_builder/src/pubspec_info/map_required.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import 'unity_project.dart';

class PubspecInfo {
  PubspecInfo({
    required this.pubspecFilePath,
    required this.unityProject,
    required this.flutterBuildVersionFileName,
    required this.unityExecutablePath,
  });

  static const String _pubspecKey = 'flutter_unity_builder';

  final String pubspecFilePath;
  final UnityProject unityProject;
  final String flutterBuildVersionFileName;
  final String unityExecutablePath;

  static Future<PubspecInfo> fromPubspec([String? pubspecFullPath]) async {
    final pubspecFile =
        File(pubspecFullPath ?? ('${Directory.current.path}/pubspec.yaml'));
    final fields =
        (await pubspecFile.readAsString()).toPubspecYaml().customFields;
    if (!fields.containsKey(_pubspecKey)) {
      throw Exception('Pubspec do not contains key: $_pubspecKey');
    }
    final flutterUnityBuilderInfo = fields[_pubspecKey];
    if (flutterUnityBuilderInfo == null) {
      throw Exception('The key $_pubspecKey has not values');
    }
    if (flutterUnityBuilderInfo is! Map<String, dynamic>) {
      throw Exception('The key $_pubspecKey has worng value type');
    }
    final unityMap = MapRequired(flutterUnityBuilderInfo);

    return PubspecInfo(
      pubspecFilePath: pubspecFile.path,
      flutterBuildVersionFileName:
          unityMap.required('flutter_build_version_file_name'),
      unityProject: UnityProject.fromMap(unityMap.required('unity_project')),
      unityExecutablePath: unityMap.required('unity_executable_location'),
    );
  }

  String buildFolderPath(String platformFolder) =>
      p.join(p.dirname(pubspecFilePath), platformFolder, 'UnityLibrary');

  @override
  String toString() => 'UnityBuilderInfo(unityProject: $unityProject, '
      'flutterBuildVersionFileName: $flutterBuildVersionFileName, '
      'unityExecutablePath: $unityExecutablePath)';
}
