import 'map_required.dart';

class Git {
  Git.fromMap(MapRequired map)
      : url = map.required('url'),
        ref = map.required('ref'),
        projectFoler = map.notRequired('project_foler');

  final String url;
  final String ref;
  final String? projectFoler;

  @override
  String toString() => 'Git(url: $url, ref: $ref, projectFoler: $projectFoler)';
}
