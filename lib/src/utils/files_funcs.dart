import 'dart:io';
import 'package:path/path.dart' as p;

import 'extensions.dart';

void modifyFileReplacingSync(String filePath, Map<Pattern, String> replaces) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  String fileText = file.readAsStringSync();
  for (var key in replaces.keys) {
    final value = replaces[key];
    if (value == null) continue;
    fileText = fileText.replaceAll(key, value);
  }
  file.writeAsStringSync(fileText);
}

Future<void> copyFilesOrDirs(
  String originPath,
  String destinationPath, {
  bool recursive = false,
  void Function(String path, String destinationPath)? print,
}) async {
  if (print != null) print(originPath, destinationPath);

  if (FileSystemEntity.isDirectorySync(originPath)) {
    if (recursive) {
      for (var fileOrDir in Directory(originPath).listSync()) {
        await copyFilesOrDirs(fileOrDir.path, destinationPath, print: print);
      }
    } else {
      if (Directory(originPath).existsSync()) {
        await Directory(originPath).copyFromCLI(destinationPath);
      }
    }
  } else if (FileSystemEntity.isFileSync(originPath)) {
    File(p.join(destinationPath, p.basename(originPath)))
        .writeAsStringSync(File(originPath).readAsStringSync());
  }
}

Future<void> deleteFilesOrDirs(List<String> paths,
    [Function(String path)? print]) async {
  for (var path in paths) {
    if (print != null) print(path);
    if (FileSystemEntity.isFileSync(path)) {
      await File(path).deleteIfExist(recursive: true);
    } else {
      await Directory(path).deleteIfExist(recursive: true);
    }
  }
}
