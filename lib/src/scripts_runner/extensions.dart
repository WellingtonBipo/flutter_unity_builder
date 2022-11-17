extension DurationExt on Duration {
  String get inTimeFormat =>
      '${(inSeconds / 60).floor()}m ${(inSeconds % 60).floor()}s ${(inMilliseconds % 1000).floor()}ms';
}

extension IterableExt<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
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
