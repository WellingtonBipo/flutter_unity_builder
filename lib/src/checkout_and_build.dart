import 'package:flutter_unity_builder/src/scripts_runner/scripts_runner.dart';

import 'build_unity_project/unity_builder.dart';
import 'checkout_unity_project/checkout_unity_project.dart';
import 'pubspec_info/pubspec_info.dart';

class CheckoutAndBuild extends ScriptsRunner {
  CheckoutAndBuild(
      {required PubspecInfo pubspecInfo, required BuildPlatform buildPlatform})
      : super(
          name: 'Checkout And Build',
          args: [],
          scripts: [
            CheckoutUnityProject(pubspecInfo: pubspecInfo),
            UnityBuilder(
                pubspecInfo: pubspecInfo, buildPlatform: buildPlatform),
          ],
        );
}
