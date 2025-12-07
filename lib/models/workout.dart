import 'package:uuid/uuid.dart';
import 'route_point.dart';

class Workout {
  String id;
  String userId;
  String type; // 'run' or 'cycle'
  DateTime startTime;
  DateTime? endTime;
  double distanceMeters;
  int version;
  bool synced;
  List<RoutePoint> points;

  Workout({
    String? id,
    required this.userId,
    this.type = 'run',
    DateTime? startTime,
    this.endTime,
    this.distanceMeters = 0.0,
    this.version = 0,
    this.synced = false,
    List<RoutePoint>? points,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        points = points ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type,
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime?.toUtc().toIso8601String(),
    'distanceMeters': distanceMeters,
    'version': version,
    'synced': synced ? 1 : 0,
  };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
    id: m['id'],
    userId: m['userId'],
    type: m['type'] ?? 'run',
    startTime: DateTime.parse(m['startTime']).toLocal(),
    endTime: m['endTime'] != null ? DateTime.parse(m['endTime']).toLocal() : null,
    distanceMeters: (m['distanceMeters'] ?? 0).toDouble(),
    version: (m['version'] ?? 0) as int,
    synced: (m['synced'] ?? 0) == 1,
  );
}
