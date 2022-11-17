import 'package:flutter_unity_builder/src/pubspec_info/pubspec_info.dart';

import '../scripts_runner/scripts_runner.dart';

class WebPostBuildScriptsRunner extends ScriptsRunner {
  final PubspecInfo pubspecInfo;

  WebPostBuildScriptsRunner({
    required this.pubspecInfo,
  }) : super(
          name: 'Web post build changes',
          scripts: [],
          args: [],
        );

  @override
  List<Script> get scripts => [];
}
