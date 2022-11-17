import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';

extension DurationExt on Duration {
  String get inTimeFormat =>
      '${(inSeconds / 60).floor()}m ${(inSeconds % 60).floor()}s ${(inMilliseconds % 1000).floor()}ms';
}

extension ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

extension IterableExt<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}

extension FileSystemEntityExtension on FileSystemEntity {
  Future<void> deleteIfExist({bool recursive = false}) async {
    if (await exists()) await delete(recursive: recursive);
  }

  void deleteSyncIfExist({bool recursive = false}) {
    if (existsSync()) deleteSync(recursive: recursive);
  }
}

extension ExtensioDirectory on Directory {
  Future<void> copyFromCLI(String destinationPath) async {
    if (path == destinationPath) return;
    if (!existsSync()) return;

    var destPath = destinationPath;
    if (p.basename(path) == p.basename(destinationPath)) {
      destPath =
          destinationPath.replaceAll('/${p.basename(destinationPath)}', '');

      final destDir = Directory(destPath);
      if (destDir.existsSync()) destDir.deleteSync(recursive: true);
      destDir.createSync(recursive: true);
    }

    await Shell().run('cp -R $path $destPath');
  }
}

extension StrinExt on String {
  String commentLine(bool comment, {String comentChar = '//'}) {
    String newLine = this;
    if (comment) {
      if (!trim().startsWith(comentChar)) {
        final lineSplited = split('');
        int? idxFirstLettter;
        for (var i = 0; i < lineSplited.length; i++) {
          if (lineSplited[i] != ' ') {
            idxFirstLettter = i;
            break;
          }
        }
        if (idxFirstLettter == null) throw Exception('Line has no letters');
        newLine = (lineSplited..insert(idxFirstLettter, '$comentChar ')).join();
      }
    } else {
      if (trim().startsWith(comentChar)) {
        newLine = replaceFirst('$comentChar ', '');
      }
    }
    return newLine;
  }
}
