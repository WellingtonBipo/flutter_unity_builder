class MapRequired {
  final Map<String, dynamic> _map;
  MapRequired(this._map);

  dynamic required(String key) {
    void e(String message) => throw Exception(message);
    final v = _map[key];
    if (!_map.containsKey(key)) e('No key "$key" found on pubspec');
    if (v == null) e('The "$key" has no value on pubspec');
    if (v is Map<String, dynamic>) return MapRequired(v);
    return v;
  }

  dynamic notRequired(String key) {
    final v = _map[key];
    if (v is Map<String, dynamic>) return MapRequired(v);
    return v;
  }
}
