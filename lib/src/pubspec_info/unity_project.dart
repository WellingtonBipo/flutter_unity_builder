import 'package:flutter_unity_builder/src/pubspec_info/map_required.dart';

import 'git.dart';

class UnityProject {
  UnityProject({
    required this.git,
    required this.repoLocalPath,
  });
  final Git git;
  final String repoLocalPath;

  factory UnityProject.fromMap(MapRequired map) => UnityProject(
        git: Git.fromMap(map.required('git')),
        repoLocalPath: map.required('repo_local_path'),
      );

  @override
  String toString() => 'UnityProject(git: $git, localPath: $repoLocalPath)';
}
