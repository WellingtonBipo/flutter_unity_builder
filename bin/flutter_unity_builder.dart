import 'package:flutter_unity_builder/src/build_unity_project/unity_builder.dart';
import 'package:flutter_unity_builder/src/checkout_and_build.dart';
import 'package:flutter_unity_builder/src/pubspec_info/pubspec_info.dart';

//Args
final _kbuildTarget = 'build_target=';

void main(List<String> args) async {
  CheckoutAndBuild(
          pubspecInfo: await PubspecInfo.fromPubspec(),
          // pubspecInfo: await PubspecInfo.fromPubspec(
          //     '${Directory.current.path}/example/pubspec.yaml')
          buildPlatform: _getBuildPlatform(args))
      .run();
}

BuildPlatform _getBuildPlatform(List<String> args) {
  final buildTarget = args.firstWhere(
    (e) => e.contains(_kbuildTarget),
    orElse: () =>
        throw Exception('Should have an argument "${_kbuildTarget}TARGET"'),
  );
  final target = buildTarget.replaceAll(_kbuildTarget, '');

  return BuildPlatform.values.firstWhere(
    (e) => e.name == target,
    orElse: () => throw Exception(
        'Targets => ${BuildPlatform.values.map((e) => e.name)}'),
  );
}
