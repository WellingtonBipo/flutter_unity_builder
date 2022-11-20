This package works with [flutter_unity_widget](https://pub.dev/packages/flutter_unity_widget) and Unity CLI to allow keep Unity project separeted from Flutter project.

## Features

- Checkout speceific ref from Unity project
- Build unity project through Unity CLI
- Choose platform target from "web", "ios" or "android".
- Copy built files inside platform folder
- Run a post build to integrate unity projetct inside flutter project.

## Getting started

- Add flutter_unity_builder to dev_dependencies.
- Follow the steps described in flutter_unity_widget package.
- Before use the CLI for the first time, open the unity project from GUI.

## Usage
Run pub command chosing one of the targets "web", "ios" or "android".

```
dart run flutter_unity_builder build_target=web
```
On pubspec.yaml on the root path of application, should set the configurations of flutter_unity_builder.

```yaml
flutter_unity_builder:
  unity_project:
    repo_local_path: REQUIRED - Folder to checkout repository project
    git:
      url: REQUIRED
      ref: REQUIRED
      project_foler: NOT REQUIRED - Folder inside repository folder where unity project is located.
  flutter_build_version_file_name: REQUIRED - File that holds version of Unity Project built.
  unity_executable_location: REQUIRED - Unity executable program to execute Unity CLI
```

<!-- ## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more. -->
